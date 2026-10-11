class TetrisWindow < Gosu::Window
  attr_accessor :current_screen

  def initialize
    super 400, 600

    self.caption = App.name

    @current_screen = SplashScreen.new(400,600,self)
  end

  def draw
    Sprites::MOUSE_CURSOR.draw(self.mouse_x, self.mouse_y, 99) if @current_screen&.needs_cursor?
    @current_screen&.draw
  end

  def update
    @current_screen&.update
    @current_screen = @current_screen.next_screen if @current_screen&.next_screen
  end

  def button_down(id)
    case id
    when Gosu::KB_ESCAPE
      close
    when @current_screen.nil?, @current_screen.button_down(id) == :super
      super
    else
      super
    end
  end
end
