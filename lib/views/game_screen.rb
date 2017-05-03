class GameScreen < Screen
  include Suspendable
  def suspended?
    @game_state.paused? || @game_state.ended?
  end

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
    if @game_state.ended?
      @ended_for ||=0
      @ended_for += 1
      @next_screen = MenuScreen.new(@width, @height) if @ended_for > 30
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

