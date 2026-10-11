class GameScreen < Screen
  def initialize(width, height, window, game_state)
    super(width, height, window)

    @game_state = game_state
    @game = Game.new(@game_state, input: GosuInput.new, audio: Sounds)

    @background = Gosu::Image.new((App.asset_root / 'Bck.png').to_s)
    @next_piece = NextPiece.new(200,200, @game.queue)
    @board_view = BoardView.new(@game.board)
    @pause_overlay = PauseOverlay.new(400,600, @game_state)
    @font = Gosu::Font.new(50, name: (App.asset_root/'fonts'/'Pacifico'/'Pacifico-Regular.ttf').to_s)
  end

  def draw
    Gosu.clip_to(0,0,@width,@height) do
      @background.draw(0,0,0)
      @font.draw_text("Level",300,20,9)
      @font.draw_text("#{@game_state.junk_level}:#{@game_state.speed_level}",300,40,9)
      @font.draw_text("Rows",300,70,9)
      @font.draw_text(@game_state.rows_cleared.to_s,300,90,9)
      @font.draw_text("Score",300,120,9)
      @font.draw_text(@game_state.score.to_s,300,140,9)
      Gosu.translate(17,0) do
        @board_view.draw
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
    @game.update
    if @game.over?
      if @game_state.won
        g = GameState.new
        g.junk_level = @game_state.junk_level + 1
        @next_screen = GameScreen.new(width,height,window,g)
      else
        @next_screen = Menu::MainScreen.new(self)
      end
    end
  end

  def button_down(id)
    case id
    when *GosuInput::PAUSE
      @game.toggle_pause
    else
      :super
    end
  end

  def next_screen
    @next_screen
  end
end

