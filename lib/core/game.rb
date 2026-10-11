# One game in progress: the board, the upcoming piece and the score, advanced one frame per update.
class Game
  include Suspendable
  def suspended?
    @state.paused? || @state.ended?
  end

  # Board size in pixels; with 30 pixel squares that's 9 columns and 20 rows.
  BOARD_WIDTH = 274
  BOARD_HEIGHT = 592

  # Frames the end of a game stays on screen before over? is true.
  ENDED_DELAY = 30

  attr_reader :state, :board, :queue

  def initialize(state, input: nil, audio: nil)
    @state = state
    @state.controls = Controls.new(input) if input
    @state.audio = audio if audio

    @queue = PieceQueue.new(@state)
    @board = Board.new(BOARD_WIDTH, BOARD_HEIGHT, @state)
    @board.current_piece = @queue.pop
    @ended_for = 0
  end

  def update
    @ended_for += 1 if @state.ended?
    _advance
  end

  def over?
    @ended_for > ENDED_DELAY
  end

  def toggle_pause
    @state.paused = !@state.paused
  end

  suspendable def _advance
    @board.update
    @board.current_piece = @queue.pop if @board.needs_next_piece?
  end
end
