require_relative './test_helper'

describe MainBoard do
  def main_board
    MainBoard.new(154,310)
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
    m = MainBoard.new(291,592,5)
    m.current_piece = Piece::Q
    test_window = TestWindow.new(274+17,592,[m],650) do |current_widget, current_time|
      case current_time
      when 5,10,15,20,140,145
        m.move_piece_left
      when 400,405,450,455,460,465,480
        m.move_piece_right
      when 470
        current_widget.rotate_piece
      end

      if current_widget.current_piece.nil?
        if current_time < 420
          current_widget.current_piece = Piece::Q
        else
          current_widget.current_piece = Piece::I
        end
      end
    end
    test_window.show
  end
end

