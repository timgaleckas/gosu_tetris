# Draws a Square with its level's sprite, shrinking as it disappears and offset while it drops,
# with borders on the sides that don't join a same-colored neighbor.
class SquareView < Widget
  attr_reader :square

  def self.draw(square, x, y, z)
    scale = 1 - (square.disappearing.to_f / Square::DISAPPEAR_LIMIT)
    Gosu.scale(scale, scale, x+(Sprites::SQUARE_WIDTH/2), y+(Sprites::SQUARE_HEIGHT/2)) do
      level_index = (square.game_state ? square.game_state.speed_level : 0) % 10
      index = level_index * 8 + square.color_index
      Sprites::SQUARES[index].draw(x, y-square.dropping, z)
      border_index = [square.left, square.right, square.up, square.down].map do |neighbor|
        !square.permalocked? && square.color_index == neighbor&.color_index ? "0" : "1"
      end.join.to_i(2)

      Sprites::BORDERS[border_index].draw(x, y-square.dropping, z+1)
    end
  end

  def initialize(square)
    super(Square.width, Square.height)
    @square = square
  end

  def draw(x, y, z)
    self.class.draw(@square, x, y, z)
  end
end
