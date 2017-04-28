class TetrisWindow < Gosu::Window
  WIDTH, HEIGHT = 400, 600

  def initialize
    super WIDTH, HEIGHT

    self.caption = "Tetris"

    @game_state = GameState.new
    @background = Gosu::Image.new('assets/Bck.png')
    @next_piece = NextPiece.new(200,200, @game_state)
    @main_board = MainBoard.new(274,592, @game_state)
    @pause_screen = PauseScreen.new(400,600, @game_state)
    @main_board.current_piece = @next_piece.pop
  end

  def draw
    @background.draw(0,0,0)
    Gosu.translate(17,0) do
      @main_board.draw
    end
    Gosu.translate(296,337) do
      Gosu.scale(0.5,0.5) do
        @next_piece.draw
      end
    end
    @pause_screen.draw
  end

  def update
    @main_board.update
    unless @main_board.current_piece
      @main_board.current_piece = @next_piece.pop
    end
  end

  def button_down(id)
    case id
    when Gosu::KB_ESCAPE
      close
    when Gosu::KB_A
      @next_piece.pop
    when Gosu::KB_B
    when Gosu::KB_LEFT
      @main_board.pressing_left = true
    when Gosu::KB_RIGHT
      @main_board.pressing_right = true
    when Gosu::KB_UP
      @main_board.rotate_piece
    when Gosu::KB_DOWN
      @main_board.pressing_down = true
    when Gosu::KB_RETURN
      @game_state.paused = !@game_state.paused
    else
      super
    end
  end

  def button_up(id)
    case id
    when Gosu::KB_LEFT
      @main_board.pressing_left = false
    when Gosu::KB_RIGHT
      @main_board.pressing_right = false
    when Gosu::KB_DOWN
      @main_board.pressing_down = false
    else
      super
    end
  end
end
