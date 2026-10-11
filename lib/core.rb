# The game rules in plain Ruby, with no Gosu or gem dependencies, so any frontend can run them.
# Frontends supply input (held?(action)) and audio (play(name)); see Game.
require_relative './core/suspendable'
require_relative './core/tunables'
require_relative './core/audio'
require_relative './core/controls'
require_relative './core/square'
require_relative './core/piece'
require_relative './core/game_state'
require_relative './core/board'
require_relative './core/piece_queue'
require_relative './core/game'
