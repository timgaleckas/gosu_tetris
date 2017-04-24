class TetrisWindow < Gosu::Window
  WIDTH, HEIGHT = 400, 600

  def initialize
    super WIDTH, HEIGHT

    self.caption = "Tetris"

    @background = Gosu::Image.new('assets/Bck.png')
    @next_piece = NextPiece.new(200,200)
    @main_board = MainBoard.new
    @main_board.current_piece = @next_piece.pop
  end

  def draw
    @background.draw(0,0,0)
    Gosu.translate(19,0) do
      @main_board.draw
    end
    Gosu.translate(296,337) do
      Gosu.scale(0.5,0.5) do
        @next_piece.draw
      end
    end
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
      @main_board.move_piece_left
    when Gosu::KB_RIGHT
      @main_board.move_piece_right
    when Gosu::KB_UP
      @main_board.rotate_piece
    when Gosu::KB_DOWN
      @main_board.move_piece_down
    else
      super
    end
  end
end
