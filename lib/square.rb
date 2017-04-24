class Square
  def initialize(color_index)
    @image = Sprites::SQUARES[color_index] if color_index
  end

  def blank?
    !!@image
  end

  def draw(x, y, z)
    @image.draw(x, y, z) if @image
  end

  def self.height
    Sprites::SQUARE_HEIGHT
  end

  def self.width
    Sprites::SQUARE_WIDTH
  end
end
