class SplashScreen < Screen
  def initialize(width, height)
    super(width, height)
    @time_remaining = 120
  end

  def update
    @time_remaining -= 1
  end

  def next_screen
    @time_remaining <= 0 && GameScreen.new(@width, @height, GameState.new)
  end
end
