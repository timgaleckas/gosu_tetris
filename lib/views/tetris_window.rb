class TetrisWindow < Gosu::Window
  def initialize
    super 400, 600

    self.caption = App.name

    @current_screen = SplashScreen.new(400,600,self)
  end

  def draw
    Sprites::MOUSE_CURSOR.draw(self.mouse_x, self.mouse_y, 99) if @current_screen.try(:needs_cursor?)
    @current_screen.try(:draw)
  end

  def update
    @current_screen.try(:update)
    @current_screen = @current_screen.next_screen if @current_screen.try(:next_screen)
  end

  def button_down(id)
    case id
    when Gosu::KbEscape
      close
    when @current_screen.nil?, @current_screen.button_down(id) == :super
      super
    else
      super
    end
  end
end
