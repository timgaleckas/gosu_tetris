class Menu::GameModeScreen < Menu::Screen
  def initialize(screen)
    super(screen, [
      [
        Menu::Button.new('classic', screen.width/2, screen.height/5 * 2.5) do
          game_state = GameState.new
          game_state.junk_level = 0
          game_state.multicolor = false
          game_state.drop_cleared_rows = true
          game_state.gravity = false
          @next_screen = GameScreen.new(screen.width, screen.height, screen.window, game_state)
        end
      ],[
        Menu::Button.new('next', screen.width/2, screen.height/5 * 4) do
          game_state = GameState.new
          @next_screen = GameScreen.new(screen.width, screen.height, screen.window, game_state)
        end
      ]
    ])
    @font = Gosu::Font.new(@window,App.asset_root/'fonts'/'Pacifico'/'Pacifico-Regular.ttf',200)
  end

  def draw
    super
    @font.draw("Modes", 40, 0, 4)
  end
end
