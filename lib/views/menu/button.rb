class Menu::Button
  attr_accessor :hovered
  attr_accessor :left, :right, :up, :down
  attr_reader :action

  def initialize(name, center_x, center_y, &action)
    @name = name
    @button_image = Gosu::Image.new(App.asset_root / 'buttons' / "#{name}.png")
    @hovered_button_image = Gosu::Image.new(App.asset_root / 'buttons' / "#{name}_hovered.png")
    @x1 = center_x - @button_image.width/2
    @x2 = center_x + @button_image.width/2
    @y1 = center_y - @button_image.height/2
    @y2 = center_y + @button_image.height/2
    @action = action
  end

  def draw
    @hovered ? @hovered_button_image.draw(@x1,@y1,2) : @button_image.draw(@x1,@y1,2)
  end

  def update
  end

  def hovered?
    !!@hovered
  end

  def within_bounds?(x,y)
    @x1 <= x && @x2 >= x &&
      @y1 <= y && @y2 >= y
  end
end
