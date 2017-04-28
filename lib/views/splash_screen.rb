class SplashScreen < Screen
  def initialize(width, height)
    super(width, height)
    @time_remaining = 120
    @image = Gosu::Image.new('./assets/splash_screen.gif')
  end

  def draw
    @image.draw(0,0,1)
  end

  def update
    @time_remaining -= 1
  end

  def next_screen
    @time_remaining <= 0 && GameScreen.new(@width, @height, GameState.new)
  end
end
