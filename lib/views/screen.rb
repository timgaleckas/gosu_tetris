class Screen
  attr_reader :width, :height, :window

  def initialize(width_or_screen, height=nil, window=nil)
    case width_or_screen
    when Screen
      @width = width_or_screen.width
      @height = width_or_screen.height
      @window = width_or_screen.window
    else
      @width, @height = width_or_screen, height
      @window = window
    end
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
