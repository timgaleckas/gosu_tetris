class MainBoard
  attr_reader :current_piece

  def initialize
    @rows = [[Square.new(0)]*9]*20
    @speed = 1
  end

  def current_piece=(piece)
    @current_piece = piece
    @current_piece_column = 4
    @current_piece_y = 0
  end

  def draw
    @rows.each_with_index do |row, row_index|
      row.each_with_index do |square, square_index|
        square.draw(square_index * Square.width, 562 - row_index * Square.height, 1)
      end
    end
    if @current_piece
      @current_piece.draw(@current_piece_column*Square.width, @current_piece_y, 2)
    end
  end

  def move_piece_down
    @current_piece_y += 1
  end

  def move_piece_left
    @current_piece_column -= 1 if @current_piece_column > 0
  end

  def move_piece_right
    @current_piece_column += 1 if @current_piece_column < (9 - @current_piece.squares_wide)
  end

  def rotate_piece
    @current_piece = @current_piece.rotated_right
  end

  def update
    @current_piece_y += @speed
    _place_piece if _collision_detected?
  end

  def _collision_detected?
    @current_piece && @current_piece_y + @current_piece.height > 590
  end

  def _place_piece
    @current_piece = nil
  end
end
