class GameScreen < Screen
  include Suspendable
  def suspended?
    @game_state.paused? || @game_state.ended?
  end

  def initialize(width, height, window, game_state)
    super(width, height, window)

    @game_state = game_state

    @background = Gosu::Image.new('assets/Bck.png')
    @next_piece = NextPiece.new(200,200, @game_state)
    @main_board = MainBoard.new(274,592, @game_state)
    @pause_overlay = PauseOverlay.new(400,600, @game_state)
    @main_board.current_piece = @next_piece.pop
    @font = Gosu::Font.new(@window,App.asset_root/'fonts'/'Pacifico'/'Pacifico-Regular.ttf',50)
  end

  def draw
    Gosu.clip_to(0,0,@width,@height) do
      @background.draw(0,0,0)
      @font.draw("Level",300,20,9)
      @font.draw("#{@game_state.junk_level}:#{@game_state.speed_level}",300,40,9)
      @font.draw("Rows",300,70,9)
      @font.draw(@game_state.rows_cleared,300,90,9)
      @font.draw("Score",300,120,9)
      @font.draw(@game_state.score,300,140,9)
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
    if @game_state.ended?
      @ended_for ||=0
      @ended_for += 1
      if @ended_for > 30
        if @game_state.won
          g = GameState.new
          g.junk_level = @game_state.junk_level + 1
          @next_screen = GameScreen.new(width,height,window,g)
        else
          @next_screen = Menu::MainScreen.new(self)
        end
      end
    end
    _update
  end

  suspendable def _update
    @main_board.update
    @main_board.current_piece = @next_piece.pop if @main_board.needs_next_piece?
  end

  def button_down(id)
    case id
    when *@game_state.key_map.pause
      @game_state.paused = !@game_state.paused
    else
      :super
    end
  end

  def next_screen
    @next_screen
  end
end

