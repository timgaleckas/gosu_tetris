# Plays a Game one update per frame with scripted input and seeded randomness,
# and records a frame-by-frame trace. The trace is the reference for how the
# game plays; see test_golden.rb.
class Simulation
  # What the agent can hold, as the actions Controls asks about.
  INPUTS = {
    left:         [:left],
    right:        [:right],
    down:         [:down],
    rotate_right: [:rotate_right],
    rotate_left:  [:rotate_left],
    left_down:    [:left, :down],
    right_down:   [:right, :down],
    none:         []
  }.freeze

  # Holds a random action for a while, then switches, like a player mashing buttons.
  class Agent
    attr_reader :held_action

    def initialize(seed)
      @rng = Rng.new(seed * 7919 + 1)
      @held_action = :none
    end

    # Call once per frame, before the game updates.
    def advance
      @held_action = @rng.sample(INPUTS.keys) if @rng.rand(100) < 8
    end

    def held?(action)
      INPUTS.fetch(@held_action).include?(action)
    end
  end

  class RecordingAudio
    attr_accessor :played

    def initialize
      @played = []
    end

    def play(name)
      @played << name
    end
  end

  attr_reader :game, :trace

  # setup: optional block receiving the Board before play starts, to arrange it.
  def initialize(seed:, frames:, game_state_options: {}, &setup)
    @seed = seed
    @frames = frames
    @game_state_options = game_state_options
    @setup = setup
  end

  def run
    agent = Agent.new(@seed)
    audio = RecordingAudio.new

    state = GameState.new
    state.rng = Rng.new(@seed)
    @game_state_options.each { |attribute, value| state.send("#{attribute}=", value) }

    @game = Game.new(state, input: agent, audio: audio)
    if @setup
      @setup.call(@game.board)
      @game.board._relink_and_relock_squares
    end

    @trace = []
    previous_board = nil
    @frames.times do |frame|
      agent.advance
      audio.played = []

      @game.update

      board = _board_dump
      @trace << _frame_line(frame, agent.held_action, audio.played)
      @trace << board if board != previous_board
      previous_board = board

      break if state.ended?
    end
    @trace << "end won=#{!!state.won} lost=#{!!state.lost}"
    self
  end

  def _frame_line(frame, held, sounds)
    board = @game.board
    state = @game.state
    piece = board.current_piece
    piece_state =
      if piece
        x = board.instance_variable_get(:@cursor_x)
        y = board.instance_variable_get(:@cursor_y)
        "piece=#{piece.instance_variable_get(:@color_index)}/r#{piece._rotation} x=#{_num(x)} y=#{_num(y)}" \
          " rest=#{board.instance_variable_get(:@current_piece_resting_for)}"
      else
        "piece=-"
      end
    [
      "f#{frame}",
      "in=#{held}",
      piece_state,
      "pending=#{board.instance_variable_get(:@actions_pending).join(',')}",
      "score=#{state.score}",
      "rows=#{state.rows_cleared}",
      "level=#{state.speed_level}",
      ("sounds=#{sounds.join(',')}" unless sounds.empty?)
    ].compact.join(' ')
  end

  # One line per board row. Each square is "<color><flags>" where flags are
  # P permalocked, L locked, d<n> disappearing count, v<n> dropping offset.
  def _board_dump
    @game.board._rows.map do |row|
      row.map do |square|
        next '.' unless square
        flags = String.new
        flags << 'P' if square.permalocked?
        flags << 'L' if square.locked?
        flags << "d#{square.disappearing}" if square.disappearing > 0
        flags << "v#{square.dropping}" if square.dropping != 0
        "#{square.color_index}#{flags}"
      end.join(' ')
    end.map { |line| "  | #{line}" }.join("\n")
  end

  def _num(value)
    value.is_a?(Float) ? format('%.6f', value) : value.to_s
  end
end
