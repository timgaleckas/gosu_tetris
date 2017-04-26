class NextPiece
  def initialize(width, height, current=nil)
    @width, @height = width, height
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

  def pop
    last = @current
    @current = Piece::ALL.sample
    last
  end
end
