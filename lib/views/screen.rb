class Screen
  def initialize(width, height)
    @width, @height = width, height
  end

  def button_down(id)
    :super
  end

  def button_up(id)
    :super
  end

  def draw
  end

  def update
  end

  def next_screen
  end
end
