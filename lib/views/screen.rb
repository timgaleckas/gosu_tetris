class Screen
  def initialize(width, height, window)
    @width, @height = width, height
    @window = window
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

  def needs_cursor?
    false
  end
end
