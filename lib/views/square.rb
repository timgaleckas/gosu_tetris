class Square
  def initialize(color_index, game_state)
    @color_index = color_index % Sprites::SQUARES.first.size
    @game_state = game_state
  end

  def draw(x, y, z)
    Sprites::SQUARES[@game_state ? @game_state.level : 0][@color_index].draw(x, y, z)
  end

  def self.height
    Sprites::SQUARE_HEIGHT
  end

  def self.width
    Sprites::SQUARE_WIDTH
  end
end
