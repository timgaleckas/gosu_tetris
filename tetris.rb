require 'rubygems'
require 'gosu'
require 'rmagick'

require_relative './lib/sprites'
require_relative './lib/square'
require_relative './lib/piece'
require_relative './lib/next_piece'
require_relative './lib/main_board'
require_relative './lib/tetris_window'

TetrisWindow.new.show
