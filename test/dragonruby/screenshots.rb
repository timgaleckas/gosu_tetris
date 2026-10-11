# Saves the DragonRuby screens to tmp/screenshots/dr_*.png: bin/dr screenshots
require 'test/core/simulation.rb'
require 'test/core/scenarios.rb'

module ScreenshotRun
  GAME_START = 90
  SHOTS = { 5 => 'splash', 50 => 'menu', 55 => 'controls', 60 => 'options', 70 => 'levels', 85 => 'modes',
            GAME_START + 149 => 'game_150', GAME_START + 399 => 'game_400', GAME_START + 400 => 'paused',
            GAME_START + 460 => 'game_over' }.freeze

  def self.tick(args)
    tick = Kernel.tick_count
    $screen = Screens::Controls.new(Screens::Menu.main) if tick == 52
    $screen = Screens::Menu.options if tick == 57
    $screen = Screens::Menu.levels(:next) if tick == 65
    $screen = Screens::Menu.modes if tick == 80
    _start_game if tick == GAME_START
    @game.toggle_pause if tick == GAME_START + 400 || tick == GAME_START + 410
    @game.state.lost = true if tick == GAME_START + 411
    @agent.advance if @agent

    Timtris.tick(args)

    if SHOTS[tick]
      args.outputs.screenshots << { x: 0, y: 0, w: 1280, h: 720,
                                    path: "tmp/screenshots/dr_#{SHOTS[tick]}.png" }
    end
    DR.request_quit if tick > SHOTS.keys.max + 2
  end

  # A seeded game with scripted input, so the shots are the same every run.
  def self._start_game
    state = GameState.new
    state.rng = Rng.new(1)
    state.junk_level = 0
    $screen = Screens::Play.new(-> { state })
    @game = $screen.instance_variable_get(:@game)
    GoldenScenarios.scatter(10, 1).call(@game.board)
    @game.board._relink_and_relock_squares
    @agent = Simulation::Agent.new(1)
    state.controls = Controls.new(@agent)
  end
end

module Main
  def tick
    ScreenshotRun.tick(args)
  end
end
