# Saves the Gosu screens to tmp/screenshots/gosu_*.png: bundle exec ruby test/gosu/screenshots.rb
# test/dragonruby/screenshots.rb saves the same moments from the DragonRuby version.
require_relative '../../lib/app'
require_relative '../core/simulation'
require_relative '../core/scenarios'

class ScreenshotWindow < TetrisWindow
  GAME_START = 90
  SHOTS = { 5 => 'splash', 70 => 'menu', 85 => 'modes',
            GAME_START + 149 => 'game_150', GAME_START + 399 => 'game_400', GAME_START + 400 => 'paused' }.freeze
  DIR = File.expand_path('../../tmp/screenshots', __dir__)

  def update
    @tick = (@tick || -1) + 1
    @current_screen = Menu::GameModeScreen.new(@current_screen) if @tick == 80
    _start_game if @tick == GAME_START
    @game.toggle_pause if @tick == GAME_START + 400
    @agent&.advance
    if @tick == GAME_START
      # DragonRuby's Play updates on the tick it's created; match that.
      @current_screen.update
    else
      super
    end
    _save_shot(SHOTS[@tick]) if SHOTS[@tick]
    close! if @tick > SHOTS.keys.max + 2
  end

  # Gosu can't clip inside an offscreen render, so clipping is skipped in these captures
  # (only visible when a piece is above the top of the board).
  def _save_shot(name)
    FileUtils.mkdir_p(DIR)
    image = Gosu.render(400, 600) do
      Gosu.singleton_class.alias_method(:_clip_to, :clip_to)
      Gosu.define_singleton_method(:clip_to) { |*_args, &block| block.call }
      begin
        @current_screen.draw
      ensure
        Gosu.singleton_class.alias_method(:clip_to, :_clip_to)
      end
    end
    image.save(File.join(DIR, "gosu_#{name}.png"))
  end

  def _start_game
    state = GameState.new
    state.rng = Rng.new(1)
    state.junk_level = 0
    @current_screen = GameScreen.new(400, 600, self, state)
    @game = @current_screen.instance_variable_get(:@game)
    GoldenScenarios.scatter(10, 1).call(@game.board)
    @game.board._relink_and_relock_squares
    @agent = Simulation::Agent.new(1)
    state.controls = Controls.new(@agent)
  end
end

ScreenshotWindow.new.show
