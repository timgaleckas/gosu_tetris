# Holds the next piece and picks a random one to replace it.
class PieceQueue
  include Suspendable
  def suspended?
    @game_state.paused? || @game_state.ended?
  end

  attr_reader :current

  def initialize(game_state, current = nil)
    @game_state = game_state
    @current = current
    pop unless @current
  end

  suspendable def pop
    last = @current
    @current = @game_state.rng.sample(Piece::ALL).with_game_state(@game_state)
    @current.randomly_mutate_color(@game_state.rng) if @game_state.multicolor
    last
  end
end
