require_relative '../test_helper'

# Watch these with VISUAL=1.
describe SquareView do
  it "can be visually inspected" do
    s = Square.new(0, nil)

    s.right = s
    s.down = s

    test_window = TestWindow.new([[SquareView.new(s),0,0,1]],200,4) do |current_widget, current_time|
    end
    test_window.show
  end

  it "can be drawn for 11 levels and 7 colors" do
    squares = []
    0.upto(11) do |level|
      g = GameState.new
      g.speed_level = level
      0.upto(6) do |color|
        squares << [SquareView.new(Square.new(color,g)), 0,0,1]
      end
    end
    test_window = TestWindow.new(squares,1) do |current_widget, current_time|

    end
    test_window.show
  end

  it "can disappear" do
    squares = []
    s = Square.new(1,nil)
    s.disappearing += 1
    while s.disappearing?
      squares << [SquareView.new(s),0,0,0]
      s = s.dup
      s.disappearing += 1
    end

    test_window = TestWindow.new(squares,2) do |current_widget, current_time|
      _(current_widget.square.disappearing?).must_equal true
    end
    test_window.show
  end
end
