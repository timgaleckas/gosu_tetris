# DragonRuby frontend. The rules are lib/core, shared with the Gosu version (bin/tetris.rb).
require 'lib/core.rb'
require 'app/platform.rb'
require 'app/canvas.rb'
require 'app/views.rb'
require 'app/screens.rb'

module Timtris
  def self.tick(args)
    $screen ||= Screens::Splash.new
    $screen = $screen.update(args)

    $screen.render_targets(args) if $screen.respond_to?(:render_targets)
    canvas = Canvas.new(args.outputs[:screen], Screens::WIDTH, Screens::HEIGHT)
    $screen.draw(args, canvas)

    args.outputs.background_color = [0, 0, 0]
    args.outputs.sprites << { x: Screens::LEFT, y: 0, w: Screens::WIDTH * Screens::SCALE, h: 720, path: :screen }
  end
end

def tick args
  Timtris.tick(args)
end

def reset args
  $screen = nil
end
