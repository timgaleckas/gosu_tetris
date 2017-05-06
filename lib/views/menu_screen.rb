class MenuScreen < Screen
  def initialize(width, height, window)
    super
    @color = 0
    @start_button = Gosu::Image.new(App.asset_root / 'buttons' / 'start_game.png')
    @options = Gosu::Image.new(App.asset_root / 'buttons' / 'options.png')
  end

  def draw
    Gosu.draw_rect(0,0,@width,@height,Colors::MENU_BACKGROUND,1)
    @start_button.draw(@width/2 - @start_button.width/2, @height/2 - @start_button.height * 1.5,1)
    @options.draw(@width/2 - @options.width/2, @height/2 + @options.height * 0.5, 1)
  end

  def update
  end

  def button_down(id)
    @next_screen ||= GameScreen.new(@width,@height,@window,GameState.new.tap{|gs|gs.level=0})
  end

  def next_screen
    @next_screen
  end

  def needs_cursor?
    true
  end
end
