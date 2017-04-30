class GameScreen < Screen
  def initialize(width, height, game_state)
    super(width, height)

    @game_state = game_state

    @background = Gosu::Image.new('assets/Bck.png')
    @next_piece = NextPiece.new(200,200, @game_state)
    @main_board = MainBoard.new(274,592, @game_state)
    @pause_overlay = PauseOverlay.new(400,600, @game_state)
    @main_board.current_piece = @next_piece.pop
  end

  def draw
    Gosu.clip_to(0,0,@width,@height) do
      @background.draw(0,0,0)
      Gosu.translate(17,0) do
        @main_board.draw
      end
      Gosu.translate(296,337) do
        Gosu.scale(0.5,0.5) do
          @next_piece.draw
        end
      end
      @pause_overlay.draw
    end
  end

  def update
    unless @game_state.ended?
      @main_board.update
      @main_board.current_piece = @next_piece.pop if @main_board.needs_next_piece?
    end
  end

  def button_down(id)
    case id
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
      :super
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
      :super
    end
  end
end

