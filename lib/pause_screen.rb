class PauseScreen
  def initialize(width, height, game_state)
    @width, @height = width, height
    @game_state = game_state
  end

  def draw
    if @game_state.paused?
      Gosu.draw_rect(0,0,@width,@height,Gosu::Color::BLACK,98)
      Sprites::PAUSE_ICON.draw(@width/2-Sprites::PAUSE_ICON.width/2,@height/2-Sprites::PAUSE_ICON.height/2,99)
    end
  end
end
