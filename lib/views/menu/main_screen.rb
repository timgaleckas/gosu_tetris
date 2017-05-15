class Menu::MainScreen < Menu::Screen
  def initialize(screen)
    super(screen, [
      [
        Menu::Button.new('start_game', screen.width/2, screen.height/5 * 2.5) do
          @next_screen = Menu::GameModeScreen.new(self)
        end
      ],[
        Menu::Button.new('options', screen.width/2, screen.height/5 * 4)
      ]
    ])
    @font = Gosu::Font.new(@window,App.asset_root/'fonts'/'Pacifico'/'Pacifico-Regular.ttf',200)
  end

  def draw
    super
    @font.draw(App.name, 40, 0, 4)
  end
end
