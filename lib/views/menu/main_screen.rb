class Menu::MainScreen < Menu::Screen
  def initialize(width, height, window)
    super(width, height, window, [
      [
        Menu::Button.new('start_game', width/2, height/5 * 2.5) do
          @next_screen = GameScreen.new(width, height, window, GameState.new)
        end
      ],[
        Menu::Button.new('options', width/2, height/5 * 4)
      ]
    ])
    @font = Gosu::Font.new(@window,App.asset_root/'fonts'/'Pacifico'/'Pacifico-Regular.ttf',200)
  end

  def draw
    super
    @font.draw(App.name, 40, 0, 4)
  end
end
