class BoardView < Widget
  def initialize(board)
    super(board.width, board.height)
    @board = board
  end

  def draw
    Gosu.clip_to(0, 0, width, height) do
      Gosu.translate(@board.x, @board.y) do
        @board.each_settled_square do |square, x, y|
          SquareView.draw(square, x, y, 1)
        end
        @board.falling_squares.each do |(square, x, y)|
          SquareView.draw(square, x, y, 2)
        end
      end
    end
  end
end
