class Piece
  def initialize(squares)
    @squares = squares
  end

  def rotated_right
    Piece.new(@squares.transpose.map(&:reverse))
  end

  def rotated_left
    Piece.new(@squares.map(&:reverse).transpose)
  end

  def width
    squares_wide * Square.width
  end

  def height
    squares_high * Square.height
  end

  def squares_wide
    @squares.first.size
  end

  def squares_high
    @squares.size
  end

  def draw(x,y,z)
    @squares.each_with_index do |row, row_index|
      row.each_with_index do |square, square_index|
        if square
          Sprites::SQUARES[0].draw(x+square_index*Square.width, y+row_index*Square.height, z)
        end
      end
    end
  end

  def _squares
    @squares
  end

  Q = new([
    [1,1],
    [1,1]
  ])

  Z = new([
    [nil,1,1],
    [1,1,nil]
  ])

  S = new([
    [1,1,nil],
    [nil,1,1]
  ])

  T = new([
    [nil,1,nil],
    [1,1,1]
  ])

  I = new([
    [1,1,1,1]
  ])

  L = new([
    [1,1],
    [1,nil],
    [1,nil]
  ])

  J = new([
    [1,1],
    [nil,1],
    [nil,1]
  ])

  ALL = [Q,Z,S,T,I,L,J]
end
