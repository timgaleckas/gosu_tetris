require_relative '../test_helper'

# Watch these with VISUAL=1.
describe BoardView do
  def game_state
    g = GameState.new
    g.junk_level = 0
    g
  end

  it "displays properly" do
    g = game_state
    m = Board.new(291,592,g)
    m.current_piece = Piece::O.with_game_state(g)
    test_window = TestWindow.new([BoardView.new(m)],650) do |current_widget, current_time|
      m.update
      case current_time
      when 5,10,15,20,140,145
        m.move_piece_left
      when 400,405,450,455,460,465,480
        m.move_piece_right
      when 470
        m._rotate_piece_right
      when 481
        g.speed_level = 7
      end

      if m.current_piece.nil?
        if current_time < 420
          m.current_piece = Piece::O.with_game_state(g)
        else
          m.current_piece = Piece::I.with_game_state(g)
        end
      end
    end
    test_window.show
  end

  it "drops past squares of the same color and only comes to rest at the bottom" do
    g = game_state
    m = Board.new(125,119,g)

    m._rows[2][2] = Square.new(1,g)
    m._rows[3][2] = Square.new(1,g)

    m._rows[0][0] = Square.new(1,g)
    m._rows[0][1] = Square.new(1,g)
    m._rows[1][1] = Square.new(1,g)

    m._relink_and_relock_squares

    m._push_action_pending :apply_gravity
    m._push_action_pending :flush_display
    test_window = TestWindow.new([BoardView.new(m)],10) do |current_widget, current_time|
      m.update
      sleep_to_see_test
    end
    test_window.show
  end
end
