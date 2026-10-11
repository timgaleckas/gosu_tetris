require_relative '../core_helper'
require_relative './simulation'

describe Board do
  def game_state
    g = GameState.new
    g.junk_level = 0
    g
  end

  # Updates until the board has no steps pending.
  def settle(board, max_frames = 1000)
    max_frames.times do
      board.update
      return unless board._peek_action_pending
    end
    flunk "board didn't settle in #{max_frames} frames"
  end

  describe "#initialize" do
    it "figures how many squares and positions itself correctly" do
      b = Board.new(154,310,game_state)
      _(b._squares_high).must_equal 11
      _(b._squares_wide).must_equal 5
      _(b.x).must_equal 2
      _(b.y).must_equal -20
    end
  end

  describe "#_apply_gravity" do
    it "drops 1 square correctly" do
      g = game_state
      m = Board.new(65,119,g)
      s = Square.new(1,g)
      m._rows[0][0] = s
      m._push_action_pending :apply_gravity
      settle(m)
      _(m._rows.last[0]).must_equal s
    end

    it "drops a 2 square vertical piece correctly" do
      g = game_state
      m = Board.new(65,119,g)
      s1 = Square.new(1,g)
      s2 = Square.new(1,g)
      s1.down = s2
      m._rows[0][0] = s1
      m._rows[1][0] = s2
      m._push_action_pending :apply_gravity
      settle(m)
      _(m._rows[-2][0]).must_equal s1
      _(m._rows[-1][0]).must_equal s2
    end

    it "drops a 3 square J correctly" do
      g = game_state
      m = Board.new(95,119,g)
      s1 = Square.new(1,g)
      s2 = Square.new(1,g)
      s3 = Square.new(1,g)
      s1.right = s2
      s2.down = s3

      m._rows[0][0] = s1
      m._rows[0][1] = s2
      m._rows[1][1] = s3
      m._push_action_pending :apply_gravity
      settle(m)
      _(m._rows[-2][0]).must_equal s1
      _(m._rows[-2][1]).must_equal s2
      _(m._rows[-1][1]).must_equal s3
    end
  end

  describe "slide mechanics" do
    it "doesn't allow you to smash one piece into another" do
      g = game_state
      m = Board.new(305,239,g)

      (0..7).each { |row| m._rows[row][0] = Square.new(2,g) }
      (0..5).each { |row| m._rows[row][1] = Square.new(2,g) }

      m._relink_and_relock_squares

      m.current_piece = Piece::S.with_game_state(g)

      40.times{ m.update }

      initial_pieces = m._rows.flatten.compact.size + m.current_piece.squares_with_coordinates(0,0).size

      10000.times do
        m.update
        m.move_piece_left
        break if m.needs_next_piece?
      end
      _(m.needs_next_piece?).must_equal true
      _(m._rows.flatten.compact.size).must_equal initial_pieces
    end
  end

  describe "landing" do
    it "plays touch down once when the piece lands and lockdown after the lock delay" do
      g = game_state
      g.speed_level = 10
      audio = Simulation::RecordingAudio.new
      g.audio = audio
      m = Board.new(274,592,g)
      m.current_piece = Piece::O.with_game_state(g)

      sounds_by_frame = []
      300.times do
        audio.played = []
        m.update
        sounds_by_frame << audio.played
        break unless m.current_piece
      end

      touch_down_frame = sounds_by_frame.index { |s| s.include?('SFX_PieceTouchDown') }
      lockdown_frame = sounds_by_frame.index { |s| s.include?('SFX_PieceLockdown') }
      _(touch_down_frame).wont_be_nil
      _(sounds_by_frame.flatten.count('SFX_PieceTouchDown')).must_equal 1
      _(lockdown_frame - touch_down_frame).must_equal Tunables.lock_delay - 1
    end
  end

  describe "wall kicks" do
    # T in spawn orientation over a square that blocks rotating in place in
    # either direction; either a left or a right kick would fit.
    def blocked_t
      g = game_state
      m = Board.new(274,592,g)
      m.current_piece = Piece::T.with_game_state(g)
      m.instance_variable_set(:@cursor_x, 90)
      m.instance_variable_set(:@cursor_y, 300)
      m._rows[12][4] = Square.new(1,g)
      m._relink_and_relock_squares
      m
    end

    it "kicks right when rotating left from spawn" do
      m = blocked_t
      m._rotate_piece_left
      _(m.current_piece._rotation).must_equal 3
      _(m.instance_variable_get(:@cursor_x)).must_equal 120
    end

    it "kicks left when rotating right from spawn" do
      m = blocked_t
      m._rotate_piece_right
      _(m.current_piece._rotation).must_equal 1
      _(m.instance_variable_get(:@cursor_x)).must_equal 60
    end

    # The kick tables use SRS coordinates, where +y is up; the board's y grows downward.
    it "kicks up when SRS says +y" do
      m = blocked_t
      m._rows[12][3] = Square.new(1,m.instance_variable_get(:@game_state))
      m._relink_and_relock_squares
      m._rotate_piece_right
      _(m.current_piece._rotation).must_equal 1
      _(m.instance_variable_get(:@cursor_x)).must_equal 60
      _(m.instance_variable_get(:@cursor_y)).must_equal 270
    end
  end

  describe "action stack" do
    it "acts like a stack" do
      g = game_state
      m = Board.new(305,239,g)

      assert_nil m._peek_action_pending
      assert_nil m._pop_action_pending

      m._push_action_pending(:tim)

      _(m._peek_action_pending).must_equal :tim
      _(m._pop_action_pending).must_equal :tim
      assert_nil m._peek_action_pending

      m._push_action_pending :last
      m._push_action_pending :first

      _(m._peek_action_pending).must_equal :first
      _(m._pop_action_pending).must_equal :first

      _(m._peek_action_pending).must_equal :last
      _(m._pop_action_pending).must_equal :last

      assert_nil m._pop_action_pending
    end
  end
end
