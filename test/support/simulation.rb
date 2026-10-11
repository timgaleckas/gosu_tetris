# Drives a MainBoard/NextPiece pair the way GameScreen does, one update per frame,
# with scripted input and seeded randomness, and records a frame-by-frame trace.
# The trace is the reference for how the game plays; see test/test_golden.rb.
class Simulation
  # Keys the agent can hold, mapped to the Gosu ids KeyMap listens for.
  INPUTS = {
    left:         [Gosu::KB_LEFT],
    right:        [Gosu::KB_RIGHT],
    down:         [Gosu::KB_DOWN],
    rotate_right: [Gosu::KB_UP],
    rotate_left:  [Gosu::GP_0_BUTTON_0],
    left_down:    [Gosu::KB_LEFT, Gosu::KB_DOWN],
    right_down:   [Gosu::KB_RIGHT, Gosu::KB_DOWN],
    none:         []
  }.freeze

  SOUND_NAMES = Sounds.constants.each_with_object({}) do |name, names|
    sample = Sounds.const_get(name)
    names[sample] = name.to_s if sample.is_a?(Gosu::Sample)
  end

  class << self
    attr_accessor :held_buttons, :sounds_played, :running
  end
  self.held_buttons = []
  self.sounds_played = []

  attr_reader :game_state, :main_board, :trace

  # setup: optional block receiving the MainBoard before play starts, to arrange the board.
  def initialize(seed:, frames:, game_state_options: {}, &setup)
    @seed = seed
    @frames = frames
    @game_state_options = game_state_options
    @setup = setup
  end

  def run
    self.class.running = true
    _run
  ensure
    self.class.running = false
  end

  def _run
    srand(@seed)
    agent_rng = Random.new(@seed)
    KeyMap.instance_variable_set(:@pressed_for, nil)
    self.class.held_buttons = []
    self.class.sounds_played = []

    @game_state = GameState.new
    @game_state_options.each { |attribute, value| @game_state.public_send("#{attribute}=", value) }

    # Mirrors GameScreen#initialize and GameScreen#_update.
    next_piece = NextPiece.new(200, 200, @game_state)
    @main_board = MainBoard.new(274, 592, @game_state)
    if @setup
      @setup.call(@main_board)
      @main_board._relink_and_relock_squares
    end
    @main_board.current_piece = next_piece.pop

    @trace = []
    previous_board = nil
    held = :none

    @frames.times do |frame|
      held = INPUTS.keys.sample(random: agent_rng) if agent_rng.rand < 0.08
      self.class.held_buttons = INPUTS.fetch(held)
      self.class.sounds_played = []

      @main_board.update
      @main_board.current_piece = next_piece.pop if @main_board.needs_next_piece?

      board = _board_dump
      @trace << _frame_line(frame, held)
      @trace << board if board != previous_board
      previous_board = board

      break if @game_state.ended?
    end
    @trace << "end won=#{!!@game_state.won} lost=#{!!@game_state.lost}"
    self
  end

  def _frame_line(frame, held)
    piece = @main_board.current_piece
    piece_state =
      if piece
        x = @main_board.instance_variable_get(:@cursor_x)
        y = @main_board.instance_variable_get(:@cursor_y)
        "piece=#{piece.instance_variable_get(:@color_index)}/r#{piece._rotation} x=#{_num(x)} y=#{_num(y)}" \
          " rest=#{@main_board.instance_variable_get(:@current_piece_resting_for)}"
      else
        "piece=-"
      end
    sounds = self.class.sounds_played
    [
      "f#{frame}",
      "in=#{held}",
      piece_state,
      "pending=#{@main_board.instance_variable_get(:@actions_pending).join(',')}",
      "score=#{@game_state.score}",
      "rows=#{@game_state.rows_cleared}",
      "level=#{@game_state.speed_level}",
      ("sounds=#{sounds.join(',')}" unless sounds.empty?)
    ].compact.join(' ')
  end

  # One line per board row. Each square is "<color><flags>" where flags are
  # P permalocked, L locked, d<n> disappearing count, v<n> dropping offset.
  def _board_dump
    @main_board._rows.map do |row|
      row.map do |square|
        next '.' unless square
        flags = +''
        flags << 'P' if square.permalocked?
        flags << 'L' if square.locked?
        flags << "d#{square.disappearing}" if square.disappearing > 0
        flags << "v#{square.dropping}" if square.dropping != 0
        "#{square.color_index}#{flags}"
      end.join(' ')
    end.map { |line| "  | #{line}" }.join("\n")
  end

  def _num(value)
    value.is_a?(Float) ? value.round(6).to_s : value.to_s
  end
end

module Gosu
  class << self
    alias_method :_real_button_down?, :button_down?

    def button_down?(id)
      Simulation.running ? Simulation.held_buttons.include?(id) : _real_button_down?(id)
    end
  end

  class Sample
    alias_method :_real_play, :play

    # While simulating, record instead of playing so sounds show up in the trace.
    def play(*args)
      return _real_play(*args) unless Simulation.running
      Simulation.sounds_played << Simulation::SOUND_NAMES.fetch(self, '?')
      nil
    end
  end
end
