# The screens. update handles input and returns the screen to
# show next (itself to stay); render_targets fills any render targets the screen uses
# (before the 400x600 canvas is opened, so it doesn't sample last frame's); draw fills the canvas.
module Screens
  WIDTH = 400
  HEIGHT = 600
  FONT = 'assets/fonts/pacifico/pacifico-regular.ttf'.freeze
  BUTTON_FONT = 'assets/fonts/courgette/courgette-regular.ttf'.freeze

  # Draws a screen's title centred across the top. Pacifico's slant carries its ink right
  # of the glyph boxes, so centring the boxes alone leaves the word right of centre.
  def self.title(canvas, y, text, size)
    canvas.text(WIDTH / 2 - size * 0.045, y, text, size, FONT, align: 0.5)
  end

  # The settings for a fresh game in each mode.
  module Modes
    def self.classic(speed_level)
      state = GameState.new
      state.junk_level = 0
      state.multicolor = false
      state.drop_cleared_rows = true
      state.gravity = false
      state.speed_level = speed_level
      state
    end

    # Clearing every junk square wins the stage; the next has a row more.
    def self.next(junk_level, speed_level)
      state = GameState.new
      state.junk_level = junk_level
      state.speed_level = speed_level
      state
    end
  end

  class Splash
    def initialize
      @time_remaining = 50
    end

    def update(args)
      @time_remaining -= 1
      @time_remaining <= 0 ? Menu.main : self
    end

    def backdrop(args)
      Screens.window_image(args, 'assets/backdrop_splash.png')
    end

    def draw(args, canvas)
      canvas.sprite(0, 0, WIDTH, HEIGHT, 'assets/splash_screen.png')
    end
  end

  class Button
    HEIGHT = 98
    PADDING = 20
    TEXT_SIZE = 50
    TEXT_COLOR = [0xE0, 0xDA, 0xF2].freeze

    attr_accessor :hovered, :left, :right, :up, :down

    # Sized to fit label. The action returns the screen to show next, or nil to stay.
    def initialize(label, center_x, center_y, &action)
      @label = label
      text_w, _text_h = GTK.calcstringbox(label, size_px: TEXT_SIZE, font: BUTTON_FONT)
      @w = text_w.ceil + 2 * PADDING
      @h = HEIGHT
      @x1 = center_x - @w.div(2)
      @y1 = center_y - @h.div(2)
      @action = action
    end

    def draw(canvas)
      canvas.nine_slice(@x1, @y1, @w, @h, @hovered ? 'assets/button_hovered.png' : 'assets/button.png', 24, 8)
      canvas.text(@x1 + @w / 2, @y1 + @h / 2, @label, TEXT_SIZE, BUTTON_FONT, TEXT_COLOR,
                  align: 0.5, valign: 0.5)
    end

    def within_bounds?(x, y)
      @x1 <= x && @x1 + @w >= x && @y1 <= y && @y1 + @h >= y
    end

    # x: where the mouse clicked, or nil from the keyboard or gamepad.
    def select(_x)
      @action.call if @action
    end
  end

  # A number picked with left and right (or by clicking either end), saved to a
  # Settings key.
  class Stepper
    W = 320
    H = 70
    TEXT_SIZE = 40

    attr_accessor :hovered, :left, :right, :up, :down

    # zero: what to show for 0, such as 'Off'. on_change is called with each new value.
    def initialize(label, range, setting, center_y, zero: nil, &on_change)
      @label = label
      @range = range
      @setting = setting
      @zero = zero
      @on_change = on_change
      @x1 = (WIDTH - W).div(2)
      @y1 = center_y - H.div(2)
    end

    def draw(canvas)
      canvas.nine_slice(@x1, @y1, W, H, @hovered ? 'assets/button_hovered.png' : 'assets/button.png', 24, 8)
      middle = @y1 + H / 2
      value = Settings[@setting]
      canvas.text(@x1 + 20, middle, @label, TEXT_SIZE, BUTTON_FONT, Button::TEXT_COLOR, valign: 0.5)
      canvas.text(_value_x, middle, value == 0 && @zero ? @zero : value.to_s, TEXT_SIZE, BUTTON_FONT,
                  Button::TEXT_COLOR, align: 0.5, valign: 0.5)
      arrow = @hovered ? Button::TEXT_COLOR : [0x88, 0xAA, 0xCC]
      canvas.text(_value_x - 45, middle, '<', TEXT_SIZE, BUTTON_FONT, arrow, align: 0.5, valign: 0.5)
      canvas.text(_value_x + 45, middle, '>', TEXT_SIZE, BUTTON_FONT, arrow, align: 0.5, valign: 0.5)
    end

    def within_bounds?(x, y)
      @x1 <= x && @x1 + W >= x && @y1 <= y && @y1 + H >= y
    end

    def step(by)
      value = (Settings[@setting] + by).clamp(@range.min, @range.max)
      return if value == Settings[@setting]

      Settings[@setting] = value
      @on_change.call(value) if @on_change
    end

    # A click left of the value lowers it, right of it raises it.
    def select(x)
      step(x < _value_x ? -1 : 1) if x
      nil
    end

    def _value_x
      @x1 + W - 75
    end
  end

  # A grid of buttons navigated by mouse, keyboard or gamepad.
  class Menu
    BACKGROUND = [0xDD, 0xDD, 0xBB].freeze
    GAMEPAD_SELECT = [:a, :b, :x, :y, :l1, :r1, :l2, :r2, :start, :select].freeze

    def self.main
      new([
        [Button.new('Start Game', WIDTH / 2, 250) { Menu.modes }],
        [Button.new('Controls', WIDTH / 2, 370) { Controls.new(Menu.main) }],
        [Button.new('Options', WIDTH / 2, 490) { Menu.options }]
      ]) { |canvas| Screens.title(canvas, 0, 'Timtris', 200) }
    end

    def self.modes
      new([
        [Button.new('Classic', WIDTH / 2, HEIGHT / 5 * 2.5) { Menu.levels(:classic) }],
        [Button.new('Next', WIDTH / 2, HEIGHT / 5 * 4) { Menu.levels(:next) }]
      ], back: -> { Menu.main }) { |canvas| Screens.title(canvas, 0, 'Modes', 200) }
    end

    # The starting levels for mode (:classic or :next), remembered between games.
    # Start has the focus, so Enter starts at the levels last played.
    def self.levels(mode)
      rows = [[Stepper.new('Speed', 0..9, :"#{mode}_speed", 220)]]
      rows << [Stepper.new('Stage', 1..10, :next_stage, 310)] if mode == :next
      start = Button.new('Start', WIDTH / 2, 470) do
        speed = Settings[:"#{mode}_speed"]
        stage = Settings[:next_stage]
        Play.new(mode == :next ? -> { Modes.next(stage, speed) } : -> { Modes.classic(speed) })
      end
      rows << [start]
      title = mode == :next ? 'Next' : 'Classic'
      new(rows, back: -> { Menu.modes }, focus: start) do |canvas|
        Screens.title(canvas, 0, title, 150)
      end
    end

    def self.options
      new([
        [Stepper.new('Volume', 0..10, :volume, 250, zero: 'Off') { DrAudio.play($args.outputs, 'SFX_PieceMoveLR') }],
        [Button.new('Back', WIDTH / 2, 470) { Menu.main }]
      ], back: -> { Menu.main }) { |canvas| Screens.title(canvas, 0, 'Options', 150) }
    end

    # rows: the buttons, laid out in a grid for keyboard and gamepad navigation.
    # background: a color to fill the screen with first, or nil.
    # back: returns the screen Escape goes to.
    # focus: the button highlighted first (the first button if nil).
    # The block draws anything else, such as the title.
    def initialize(rows, background: BACKGROUND, back: nil, focus: nil, &decoration)
      rows.each_with_index do |row, row_index|
        row.each_with_index do |button, column_index|
          button.down = rows[row_index + 1] && rows[row_index + 1][column_index]
          button.up = rows[row_index - 1][column_index] if row_index > 0
          button.left = row[column_index - 1] if column_index > 0
          button.right = row[column_index + 1]
        end
      end
      @buttons = rows.flatten
      @background = background
      @back = back
      @decoration = decoration
      @focus = focus || @buttons.first
      @last_interaction = :keyboard
    end

    def update(args)
      next_screen = _handle_input(args)
      _update(args)
      next_screen || self
    end

    def backdrop(args)
      Screens.fill_window(args, @background) if @background
    end

    def draw(args, canvas)
      canvas.rect(0, 0, WIDTH, HEIGHT, @background) if @background
      @buttons.each { |button| button.draw(canvas) }
      @decoration.call(canvas) if @decoration
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

      if keyboard.escape && @back
        @back.call
      elsif keyboard.down_arrow || controller.down_dpad
        _move(:down)
      elsif keyboard.up_arrow || controller.up_dpad
        _move(:up)
      elsif keyboard.right_arrow || controller.right_dpad
        _move(:right)
      elsif keyboard.left_arrow || controller.left_dpad
        _move(:left)
      elsif keyboard.enter || keyboard.space || GAMEPAD_SELECT.any? { |button| controller.send(button) }
        _select(nil)
      elsif mouse.key_down.left || mouse.key_down.right
        was_mouse = @last_interaction == :mouse
        @last_interaction = :mouse
        _select(Screens.to_screen(mouse.x, mouse.y)[0]) if was_mouse
      end
    end

    def _update(args)
      mouse = args.inputs.mouse
      @last_interaction = :mouse if mouse.moved
      if @last_interaction == :mouse
        x, y = Screens.to_screen(mouse.x, mouse.y)
        @buttons.each { |button| button.hovered = button.within_bounds?(x, y) }
      elsif @buttons.none?(&:hovered)
        @focus.hovered = true
      end
    end

    def _move(direction)
      selected = @buttons.find(&:hovered)
      if selected.respond_to?(:step) && (direction == :left || direction == :right)
        selected.step(direction == :right ? 1 : -1)
        return nil
      end

      target = selected && selected.send(direction)
      if target
        target.hovered = true
        selected.hovered = false
      end
    end

    def _select(x)
      selected = @buttons.find(&:hovered)
      selected.select(x) if selected
    end
  end

  # Which keys and gamepad buttons do what; any key, click or button goes back.
  class Controls
    TEXT_COLOR = [0x3D, 0x48, 0x4C].freeze

    # back: the screen to return to.
    def initialize(back)
      @back = back
    end

    def update(args)
      inputs = args.inputs
      pressed = inputs.keyboard.key_down.truthy_keys.any? ||
                inputs.controller_one.key_down.truthy_keys.any? ||
                inputs.mouse.key_down.left || inputs.mouse.key_down.right
      pressed ? @back : self
    end

    def backdrop(args)
      Screens.fill_window(args, Menu::BACKGROUND)
    end

    def draw(args, canvas)
      canvas.rect(0, 0, WIDTH, HEIGHT, Menu::BACKGROUND)
      Screens.title(canvas, 0, 'Controls', 90)
      _section(canvas, 'Keyboard', 1, 125)
      _section(canvas, 'Gamepad', 2, 335)
      canvas.text(WIDTH / 2, 590, 'Press any key to go back', 24, BUTTON_FONT, TEXT_COLOR, align: 0.5, valign: 1)
    end

    # column: which of DrInput::LABELS' columns to list.
    def _section(canvas, title, column, y)
      canvas.text(20, y, title, 44, FONT, TEXT_COLOR)
      DrInput::LABELS.each_with_index do |labels, i|
        row_y = y + 60 + i * 30
        canvas.text(30, row_y, labels[0], 26, BUTTON_FONT, TEXT_COLOR)
        canvas.text(WIDTH - 30, row_y, labels[column], 26, BUTTON_FONT, TEXT_COLOR, align: 1)
      end
    end
  end

  # A game in progress, with the pause menu over it while paused and the game over
  # menu once it's lost.
  class Play
    BACKGROUND = 'assets/bck.png'.freeze
    DIM = [0, 0, 0, 215].freeze

    # new_state: makes the GameState for this game, and again for Restart and Retry.
    def initialize(new_state)
      @new_state = new_state
      @state = new_state.call
      @input = DrInput.new
      @audio = DrAudio.new
      @game = Game.new(@state, input: @input, audio: @audio)
    end

    def update(args)
      @input.inputs = args.inputs
      @audio.outputs = args.outputs

      return _through(@game_over, args) if @game_over

      if @input.pause_pressed?
        _toggle_pause
        return self
      end
      if @state.paused?
        @pause_menu ||= _pause_menu
        return _through(@pause_menu, args)
      end
      @pause_menu = nil

      @game.update

      if @game.over?
        if @state.won
          junk_level = @state.junk_level + 1
          new_state = @new_state
          return Play.new(lambda do
            state = new_state.call
            state.junk_level = junk_level
            state
          end)
        end
        @game_over = _game_over_menu
      end
      self
    end

    def render_targets(args)
      Views.board(args.outputs, @game.board)
    end

    def backdrop(args)
      Screens.window_image(args, 'assets/backdrop_game.png')
      _overlay.backdrop(args) if _overlay
    end

    def draw(args, canvas)
      canvas.sprite(0, 0, WIDTH, HEIGHT, BACKGROUND)
      canvas.text(300, 20, 'Level', 50, FONT)
      canvas.text(300, 40, _level, 50, FONT)
      canvas.text(300, 70, 'Rows', 50, FONT)
      canvas.text(300, 90, @state.rows_cleared.to_s, 50, FONT)
      canvas.text(300, 120, 'Score', 50, FONT)
      canvas.text(300, 140, @state.score.to_s, 50, FONT)

      canvas.sprite(17, 0, @game.board.width, @game.board.height, :board)

      Views.next_piece(canvas, @game.queue.current, 296, 337)

      _overlay.draw(args, canvas) if _overlay
    end

    def _overlay
      @game_over || (@state.paused? && @pause_menu)
    end

    def _level
      "#{@state.junk_level}:#{@state.speed_level}"
    end

    # Pausing hides the board, so a pause can't be used to plan.
    def _pause_menu
      Menu.new([
        [Button.new('Resume', WIDTH / 2, 215) { _toggle_pause; nil }],
        [Button.new('Controls', WIDTH / 2, 320) { Controls.new(self) }],
        [Button.new('Restart', WIDTH / 2, 425) { Play.new(@new_state) }],
        [Button.new('Quit', WIDTH / 2, 530) { Menu.main }]
      ], background: [0, 0, 0]) { |canvas| Screens.title(canvas, 40, 'Paused', 100) }
    end

    def _game_over_menu
      Menu.new([
        [Button.new('Retry', WIDTH / 2, 390) { Play.new(@new_state) }],
        [Button.new('Menu', WIDTH / 2, 510) { Menu.main }]
      ], background: DIM) do |canvas|
        Screens.title(canvas, 30, 'Game Over', 80)
        [['Score', @state.score], ['Rows', @state.rows_cleared], ['Level', _level]].each_with_index do |(name, value), i|
          y = 160 + i * 50
          canvas.text(WIDTH / 2 - 10, y, name, 45, FONT, align: 1)
          canvas.text(WIDTH / 2 + 10, y, value.to_s, 45, FONT)
        end
      end
    end

    def _toggle_pause
      @game.toggle_pause
      @input.suppress_held unless @state.paused?
    end

    # Updates an overlay menu, staying on this screen unless it picked another.
    def _through(menu, args)
      next_screen = menu.update(args)
      next_screen.equal?(menu) ? self : next_screen
    end
  end

  # Where the 400x600 screen sits in DragonRuby's 1280x720 window.
  SCALE = 720.0 / HEIGHT
  LEFT = (1280 - WIDTH * SCALE) / 2

  # A screen's backdrop(args) fills the whole window behind it, so the sides the screen
  # doesn't reach match it. These draw one, in window coordinates.
  def self.fill_window(args, color)
    args.outputs.sprites << { x: 0, y: 0, w: 1280, h: 720, path: :solid,
                              r: color[0], g: color[1], b: color[2], a: color[3] || 255 }
  end

  def self.window_image(args, path)
    args.outputs.sprites << { x: 0, y: 0, w: 1280, h: 720, path: path }
  end

  # Window coordinates to screen (top-left) coordinates.
  def self.to_screen(x, y)
    [(x - LEFT) / SCALE, (720 - y) / SCALE]
  end
end
