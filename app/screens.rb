# The screens, mirroring lib/views. update handles input and returns the screen to
# show next (itself to stay); render_targets fills any render targets the screen uses
# (before the 400x600 canvas is opened, so it doesn't sample last frame's); draw fills the canvas.
module Screens
  WIDTH = 400
  HEIGHT = 600
  FONT = 'assets/fonts/pacifico/pacifico-regular.ttf'.freeze

  class Splash
    def initialize
      @time_remaining = 50
    end

    def update(args)
      @time_remaining -= 1
      @time_remaining <= 0 ? Menu.main : self
    end

    def draw(args, canvas)
      canvas.sprite(0, 0, WIDTH, HEIGHT, 'assets/splash_screen.png')
    end
  end

  class Button
    attr_accessor :hovered, :left, :right, :up, :down
    attr_reader :action

    # w, h: the image's size (assets/buttons/<name>.png).
    def initialize(name, w, h, center_x, center_y, &action)
      @name = name
      @w, @h = w, h
      @x1 = center_x - w.div(2)
      @y1 = center_y - h.div(2)
      @action = action
    end

    def draw(canvas)
      canvas.sprite(@x1, @y1, @w, @h, "assets/buttons/#{@name}#{@hovered ? '_hovered' : ''}.png")
    end

    def within_bounds?(x, y)
      @x1 <= x && @x1 + @w >= x && @y1 <= y && @y1 + @h >= y
    end
  end

  # A grid of buttons navigated by mouse, keyboard or gamepad; see lib/views/menu/screen.rb.
  class Menu
    BACKGROUND = [0xDD, 0xDD, 0xBB].freeze
    GAMEPAD_SELECT = [:a, :b, :x, :y, :l1, :r1, :l2, :r2, :start, :select].freeze

    def self.main
      new('Timtris', [
        [Button.new('start_game', 296, 98, WIDTH / 2, HEIGHT / 5 * 2.5) { Menu.modes }],
        [Button.new('options', 212, 98, WIDTH / 2, HEIGHT / 5 * 4)]
      ])
    end

    def self.modes
      new('Modes', [
        [Button.new('classic', 201, 98, WIDTH / 2, HEIGHT / 5 * 2.5) do
          state = GameState.new
          state.junk_level = 0
          state.multicolor = false
          state.drop_cleared_rows = true
          state.gravity = false
          Play.new(state)
        end],
        [Button.new('next', 143, 98, WIDTH / 2, HEIGHT / 5 * 4) { Play.new(GameState.new) }]
      ])
    end

    def initialize(title, rows)
      @title = title
      rows.each_with_index do |row, row_index|
        row.each_with_index do |button, column_index|
          button.down = rows[row_index + 1] && rows[row_index + 1][column_index]
          button.up = rows[row_index - 1][column_index] if row_index > 0
          button.left = row[column_index - 1] if column_index > 0
          button.right = row[column_index + 1]
        end
      end
      @buttons = rows.flatten
      @last_interaction = :mouse
    end

    def update(args)
      next_screen = _handle_input(args)
      _update(args)
      next_screen || self
    end

    def draw(args, canvas)
      canvas.rect(0, 0, WIDTH, HEIGHT, BACKGROUND)
      @buttons.each { |button| button.draw(canvas) }
      canvas.text(40, 0, @title, 200, FONT)
    end

    def _handle_input(args)
      keyboard = args.inputs.keyboard.key_down
      controller = args.inputs.controller_one.key_down
      mouse = args.inputs.mouse

      if keyboard.truthy_keys.any?
        @last_interaction = :keyboard
      elsif args.inputs.controller_one.truthy_keys.any?
        @last_interaction = :gamepad
      end

      if keyboard.down_arrow || controller.down_dpad
        _move(:down)
      elsif keyboard.up_arrow || controller.up_dpad
        _move(:up)
      elsif keyboard.right_arrow || controller.right_dpad
        _move(:right)
      elsif keyboard.left_arrow || controller.left_dpad
        _move(:left)
      elsif keyboard.enter || GAMEPAD_SELECT.any? { |button| controller.send(button) }
        _select
      elsif mouse.key_down.left || mouse.key_down.right
        was_mouse = @last_interaction == :mouse
        @last_interaction = :mouse
        _select if was_mouse
      end
    end

    def _update(args)
      mouse = args.inputs.mouse
      @last_interaction = :mouse if mouse.moved
      if @last_interaction == :mouse
        x, y = Screens.to_screen(mouse.x, mouse.y)
        @buttons.each { |button| button.hovered = button.within_bounds?(x, y) }
      elsif @buttons.none?(&:hovered)
        @buttons.first.hovered = true
      end
    end

    def _move(direction)
      selected = @buttons.find(&:hovered)
      target = selected && selected.send(direction)
      if target
        target.hovered = true
        selected.hovered = false
      end
    end

    def _select
      selected = @buttons.find(&:hovered)
      selected.action.call if selected && selected.action
    end
  end

  # A game in progress; see lib/views/game_screen.rb.
  class Play
    BACKGROUND = 'assets/bck.png'.freeze
    PAUSE_ICON = 'assets/pause.png'.freeze

    def initialize(state)
      @state = state
      @input = DrInput.new
      @audio = DrAudio.new
      @game = Game.new(@state, input: @input, audio: @audio)
    end

    def update(args)
      @input.inputs = args.inputs
      @audio.outputs = args.outputs

      @game.toggle_pause if @input.pause_pressed?
      @game.update

      if @game.over?
        if @state.won
          state = GameState.new
          state.junk_level = @state.junk_level + 1
          return Play.new(state)
        else
          return Menu.main
        end
      end
      self
    end

    def render_targets(args)
      Views.board(args.outputs, @game.board)
    end

    def draw(args, canvas)
      canvas.sprite(0, 0, WIDTH, HEIGHT, BACKGROUND)
      canvas.text(300, 20, 'Level', 50, FONT)
      canvas.text(300, 40, "#{@state.junk_level}:#{@state.speed_level}", 50, FONT)
      canvas.text(300, 70, 'Rows', 50, FONT)
      canvas.text(300, 90, @state.rows_cleared.to_s, 50, FONT)
      canvas.text(300, 120, 'Score', 50, FONT)
      canvas.text(300, 140, @state.score.to_s, 50, FONT)

      canvas.sprite(17, 0, @game.board.width, @game.board.height, :board)

      Views.next_piece(canvas, @game.queue.current, 296, 337)

      if @state.paused?
        canvas.rect(0, 0, WIDTH, HEIGHT, [0, 0, 0])
        canvas.sprite(WIDTH / 2 - 25, HEIGHT / 2 - 25, 50, 50, PAUSE_ICON)
      end
    end
  end

  # Where the 400x600 screen sits in DragonRuby's 1280x720 window.
  SCALE = 720.0 / HEIGHT
  LEFT = (1280 - WIDTH * SCALE) / 2

  # Window coordinates to screen (top-left) coordinates.
  def self.to_screen(x, y)
    [(x - LEFT) / SCALE, (720 - y) / SCALE]
  end
end
