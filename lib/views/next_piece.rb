class NextPiece < Widget
  include Suspendable
  def suspended?
    @game_state.paused? || @game_state.ended?
  end

  def initialize(width, height, game_state, current=nil)
    super(width, height)

    @game_state = game_state
    @current = current
    pop unless @current
  end

  def draw
    cursor_x = (@width/2) - (Square.width*2)
    cursor_y = (@height/2) - (Square.height*3)
    @current.squares_with_coordinates(cursor_x,cursor_y).each do |(square, x, y)|
      square.draw(x,y,2)
    end
  end

  suspendable def pop
    last = @current
    @current = Piece::ALL.sample.with_game_state(@game_state)
    @current.randomly_mutate_color if @game_state.multicolor
    last
  end
end
