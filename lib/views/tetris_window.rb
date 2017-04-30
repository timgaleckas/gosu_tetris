class TetrisWindow < Gosu::Window
  def initialize
    super 400, 600

    self.caption = "Tetris"

    @current_screen = SplashScreen.new(400,600)
  end

  def draw
    @current_screen.try(:draw)
  end

  def update
    @current_screen.try(:update)
    @current_screen = @current_screen.next_screen if @current_screen.try(:next_screen)
  end

  def button_down(id)
    case id
    when Gosu::KB_ESCAPE
      close
    when @current_screen.nil?, @current_screen.button_down(id) == :super
      super
    end
  end
end
