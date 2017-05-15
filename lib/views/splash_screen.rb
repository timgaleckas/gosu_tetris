class SplashScreen < Screen
  def initialize(width, height, window)
    super
    @time_remaining = 50
    @image = Gosu::Image.new('./assets/splash_screen.gif')
  end

  def draw
    @image.draw(0,0,1)
  end

  def update
    @time_remaining -= 1
  end

  def next_screen
    @time_remaining <= 0 && Menu::MainScreen.new(self)
  end
end
