require_relative './test_helper'

describe MainBoard do
  def game_state
    g = GameState.new
    g.junk_level = 0
    g
  end

  def main_board
    MainBoard.new(154,310,game_state)
  end

  describe "#initialize" do
    it "figures how many squares and positions itself correctly" do
      b = main_board
      b._squares_high.must_equal 11
      b._squares_wide.must_equal 5
      b._x.must_equal 2
      b._y.must_equal -20
    end
  end

  it "displays properly" do
    g = game_state
    m = MainBoard.new(291,592,g)
    m.current_piece = Piece::O.with_game_state(g)
    test_window = TestWindow.new([m],650) do |current_widget, current_time|
      case current_time
      when 5,10,15,20,140,145
        m.move_piece_left
      when 400,405,450,455,460,465,480
        m.move_piece_right
      when 470
        current_widget._rotate_piece_right
      when 481
        g.speed_level = 7
      end

      if current_widget.current_piece.nil?
        if current_time < 420
          current_widget.current_piece = Piece::O.with_game_state(g)
        else
          current_widget.current_piece = Piece::I.with_game_state(g)
        end
      end
    end
    test_window.show
  end

  describe "#_apply_gravity" do
    it "drops 1 square correctly" do
      g = game_state
      m = MainBoard.new(65,119,g)
      s = Square.new(1,g)
      m._rows[0][0] = s
      m._push_action_pending :apply_gravity
      test_window = TestWindow.new([m],10) do |current_widget, current_time|
        sleep_to_see_test
        if !current_widget._peek_action_pending
          current_widget._rows.last[0].must_equal s
          test_window.close
        end
      end
      test_window.show
    end

    it "drops a 2 square vertical piece correctly" do
      g = game_state
      m = MainBoard.new(65,119,g)
      s1 = Square.new(1,g)
      s2 = Square.new(1,g)
      s1.down = s2
      m._rows[0][0] = s1
      m._rows[1][0] = s2
      m._push_action_pending :apply_gravity
      test_window = TestWindow.new([m],10) do |current_widget, current_time|
        sleep_to_see_test
        if !current_widget._peek_action_pending
          current_widget._rows[-2][0].must_equal s1
          current_widget._rows[-1][0].must_equal s2
          test_window.close
        end
      end
      test_window.show
    end

    it "drops a 3 square J correctly" do
      g = game_state
      m = MainBoard.new(95,119,g)
      s1 = Square.new(1,g)
      s2 = Square.new(1,g)
      s3 = Square.new(1,g)
      s1.right = s2
      s2.down = s3

      m._rows[0][0] = s1
      m._rows[0][1] = s2
      m._rows[1][1] = s3
      m._push_action_pending :apply_gravity
      test_window = TestWindow.new([m],10) do |current_widget, current_time|
        sleep_to_see_test
        if !current_widget._peek_action_pending
          current_widget._rows[-2][0].must_equal s1
          current_widget._rows[-2][1].must_equal s2
          current_widget._rows[-1][1].must_equal s3
          test_window.close
        end
      end
      test_window.show
    end

    it "drops past squares of the same color and only comes to rest at the bottom" do
      g = game_state
      m = MainBoard.new(125,119,g)

      m._rows[2][2] = Square.new(1,g)
      m._rows[3][2] = Square.new(1,g)


      m._rows[0][0] = s1 = Square.new(1,g)
      m._rows[0][1] = s2 = Square.new(1,g)
      m._rows[1][1] = s3 = Square.new(1,g)

      m._relink_and_relock_squares

      m._push_action_pending :apply_gravity
      m._push_action_pending :flush_display
      test_window = TestWindow.new([m],10) do |current_widget, current_time|
        sleep_to_see_test
        unless true
          current_widget._rows[-2][0].must_equal s1
          current_widget._rows[-2][1].must_equal s2
          current_widget._rows[-1][1].must_equal s3
          test_window.close
        end
      end
      test_window.show
    end
  end

  describe "slide mechanics" do
    it "doesn't allow you to smash one piece into another" do
      g = game_state
      m = MainBoard.new(305,239,g)

      m._rows[0][0] = Square.new(2,g)
      m._rows[1][0] = Square.new(2,g)
      m._rows[2][0] = Square.new(2,g)
      m._rows[3][0] = Square.new(2,g)
      m._rows[4][0] = Square.new(2,g)
      m._rows[5][0] = Square.new(2,g)
      m._rows[6][0] = Square.new(2,g)
      m._rows[7][0] = Square.new(2,g)
      m._rows[0][1] = Square.new(2,g)
      m._rows[1][1] = Square.new(2,g)
      m._rows[2][1] = Square.new(2,g)
      m._rows[3][1] = Square.new(2,g)
      m._rows[4][1] = Square.new(2,g)
      m._rows[5][1] = Square.new(2,g)

      m._relink_and_relock_squares

      m.current_piece = Piece::S.with_game_state(g)

      40.times{ m.update }

      initial_pieces = m._rows.flatten.compact.size + m.current_piece.squares_with_coordinates(0,0).size

      test_window = TestWindow.new([m],10000) do |current_widget, current_time|
        sleep_to_see_test

        current_widget.move_piece_left

        if current_widget.needs_next_piece?
          m._rows.flatten.compact.size.must_equal initial_pieces
          test_window.close
        end
      end
      test_window.show
    end
  end

  describe "action stack" do
    it "acts like a stack" do
      g = game_state
      m = MainBoard.new(305,239,g)

      assert_nil m._peek_action_pending
      assert_nil m._pop_action_pending

      m._push_action_pending(:tim)

      m._peek_action_pending.must_equal :tim
      m._pop_action_pending.must_equal :tim
      assert_nil m._peek_action_pending

      m._push_action_pending :last
      m._push_action_pending :first

      m._peek_action_pending.must_equal :first
      m._pop_action_pending.must_equal :first

      m._peek_action_pending.must_equal :last
      m._pop_action_pending.must_equal :last

      assert_nil m._pop_action_pending
    end
  end
end
