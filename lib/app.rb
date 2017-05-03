require 'rubygems'
require 'gosu'
require 'rmagick'
require 'active_support/core_ext/object/try'
require 'filepath'

class App
  class << self
    def root
      @root ||= FilePath.new(File.expand_path("..", File.dirname(__FILE__)))
    end

    def asset_root
      @asset_root ||= root / 'assets'
    end
  end
end

require_relative './colors'
require_relative './concerns/suspendable'
require_relative './tunables'
require_relative './key_map'
require_relative './sprites'
require_relative './piece'
require_relative './game_state'

require_relative './views/tetris_window'

require_relative './views/screen'
require_relative './views/widget'

require_relative './views/splash_screen'
require_relative './views/menu_screen'

require_relative './views/game_screen'
require_relative './views/main_board'
require_relative './views/next_piece'
require_relative './views/pause_overlay'

require_relative './views/square'
