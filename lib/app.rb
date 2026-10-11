require 'rubygems'
require 'gosu'
require 'pathname'

class App
  class << self
    def root
      @root ||= Pathname.new(File.expand_path("..", File.dirname(__FILE__)))
    end

    def asset_root
      @asset_root ||= root / 'assets'
    end

    def name
      "Timtris"
    end
  end
end

require_relative './core'

require_relative './colors'
require_relative './gosu_input'
require_relative './sounds'
require_relative './sprites'

require_relative './views/tetris_window'

require_relative './views/screen'
require_relative './views/widget'

require_relative './views/menu'

require_relative './views/splash_screen'

require_relative './views/game_screen'
require_relative './views/board_view'
require_relative './views/next_piece'
require_relative './views/pause_overlay'

require_relative './views/square_view'
