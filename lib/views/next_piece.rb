class NextPiece < Widget
  def initialize(width, height, queue)
    super(width, height)
    @queue = queue
  end

  def draw
    cursor_x = (@width/2) - (Square.width*2)
    cursor_y = (@height/2) - (Square.height*3)
    @queue.current.squares_with_coordinates(cursor_x,cursor_y).each do |(square, x, y)|
      SquareView.draw(square, x, y, 2)
    end
  end
end
