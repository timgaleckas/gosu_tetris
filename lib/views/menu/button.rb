class Menu::Button
  def initialize(x,y,z,name)
    @x,@y,@z = x,y,z
    @name = name
    @button_image = App.asset_root / 'buttons' / "#{name}.png"
    @hovered_button_image = App.asset_root / 'buttons' / "#{name}_hovered.png"
  end

  def draw
    #Sprites::Menu
  end

  def update
  end

  def bounds
    [@x, @y, @x + @button_image.width, @y + @button_image.height]
  end
end
