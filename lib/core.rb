# The game rules in plain Ruby, with no Gosu or gem dependencies, so any frontend can run them.
# Frontends supply input (held?(action)) and audio (play(name)); see Game.
# Runs on MRI and DragonRuby: integer division uses div (DragonRuby's Integer#/ returns a Float),
# randomness goes through Rng, and requires use paths DragonRuby can resolve.
require_relative 'core/suspendable.rb'
require_relative 'core/tunables.rb'
require_relative 'core/rng.rb'
require_relative 'core/audio.rb'
require_relative 'core/controls.rb'
require_relative 'core/square.rb'
require_relative 'core/piece.rb'
require_relative 'core/game_state.rb'
require_relative 'core/board.rb'
require_relative 'core/piece_queue.rb'
require_relative 'core/game.rb'
