# Stages the gameplay shots for the itch.io page and saves them to tmp/promo:
#   classic_fall.png   a Classic stack with an I piece heading for the well
#   classic_clear.png  the same I a moment after landing, four rows shrinking away
#   next_stage.png     Next mode, stage 8, with a few pieces settled on the junk
# Run through bin/dr promo.
require 'test/core/simulation.rb'
require 'tools/promo/stacker.rb'

module PromoScenes
  # find_seed.rb's pick: 22 pieces from seed 6 fill nine rows with no holes.
  STACK_SEED = 6
  STACK_PIECES = 22
  CLASSIC_SPEED = 1
  NEXT_SEED = 8

  # Input that holds whatever actions it's told to.
  class Hold
    attr_accessor :actions

    def initialize
      @actions = []
    end

    def held?(action)
      @actions.include?(action)
    end
  end

  def self.tick(args)
    tick = Kernel.tick_count
    if tick == 2
      $screen, game = _classic
      @hold = Hold.new
      game.state.controls = Controls.new(@hold)
    end
    _shot(args, 'classic_fall') if tick == 8
    @hold.actions = [:down] if tick == 10
    _shot(args, 'classic_clear') if tick == 66
    $screen = _next_stage if tick == 100
    _shot(args, 'next_stage') if tick == 105

    Timtris.tick(args)
    DR.request_quit if tick > 108
  end

  # A Classic game partway in, its stack leaving the right-hand column open, with a
  # vertical I above that column.
  def self._classic
    state = Screens::Modes.classic(CLASSIC_SPEED)
    state.rng = Rng.new(3)
    _set_progress(state, CLASSIC_SPEED * 10 + 6, 3120 + CLASSIC_SPEED * 2900)
    screen = Screens::Play.new(-> { state })
    game = screen.instance_variable_get(:@game)
    board = game.board
    well = board._rows[0].size - 1
    Stacker.stack(board._rows, state, STACK_PIECES, Rng.new(STACK_SEED), well_col: well, max_height: 11)
    board._relink_and_relock_squares

    piece = Piece::I.with_game_state(state).rotated_right
    board.current_piece = piece
    piece_left = piece.squares_with_coordinates(0, 0).map { |(_, x, _)| x }.min
    board.instance_variable_set(:@cursor_x, well * Square.width - piece_left)
    board.instance_variable_set(:@cursor_y, 60)
    [screen, game]
  end

  # Next mode, stage 8, with a few pieces dropped onto the junk and left to settle.
  def self._next_stage
    state = Screens::Modes.next(8, 6)
    state.rng = Rng.new(NEXT_SEED)
    _set_progress(state, 61, 23710)
    screen = Screens::Play.new(-> { state })
    board = screen.instance_variable_get(:@game).board
    Stacker.stack(board._rows, state, 4, Rng.new(NEXT_SEED + 100), max_height: 12)

    # Settle the stack with no falling piece, so gravity pulls down what it would.
    piece = board.current_piece
    board.instance_variable_set(:@current_piece, nil)
    board._relink_and_relock_squares
    board._apply_gravity
    300.times { board.update }
    board.instance_variable_set(:@current_piece, piece)
    board.instance_variable_set(:@cursor_y, 90)
    screen
  end

  # A score and row count, so the panel doesn't read zero.
  def self._set_progress(state, rows_cleared, score)
    state.instance_variable_set(:@rows_cleared, rows_cleared)
    state.instance_variable_set(:@score, score)
  end

  def self._shot(args, name)
    args.outputs.screenshots << { x: 0, y: 0, w: 1280, h: 720, path: "tmp/promo/#{name}.png" }
  end
end

module Main
  def tick
    PromoScenes.tick(args)
  end
end
