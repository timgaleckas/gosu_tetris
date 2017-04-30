require_relative './test_helper'

describe Square do
  it "can doubly link left" do
    r = Square.new(0,nil)
    l1 = Square.new(0,nil)
    l2 = Square.new(0,nil)
    r.left = l1
    r.left.must_equal l1
    l1.right.must_equal r

    r.left = l2
    r.left.must_equal l2
    assert_nil l1.right
    l2.right.must_equal r
  end
  it "can doubly link right" do
    l = Square.new(0,nil)
    r1 = Square.new(0,nil)
    r2 = Square.new(0,nil)
    l.right = r1
    l.right.must_equal r1
    r1.left.must_equal l

    l.right = r2
    l.right.must_equal r2
    assert_nil r1.left
    r2.left.must_equal l
  end
  it "can doubly link up" do
    d = Square.new(0,nil)
    u1 = Square.new(0,nil)
    u2 = Square.new(0,nil)
    d.up = u1
    d.up.must_equal u1
    u1.down.must_equal d

    d.up = u2
    d.up.must_equal u2
    assert_nil u1.down
    u2.down.must_equal d
  end
  it "can doubly link down" do
    u = Square.new(0,nil)
    d1 = Square.new(0,nil)
    d2 = Square.new(0,nil)
    u.down = d1
    u.down.must_equal d1
    d1.up.must_equal u

    u.down = d2
    u.down.must_equal d2
    assert_nil d1.up
    d2.up.must_equal u
  end

  describe "drawing" do
    it "can be drawn for 100 levels and 9 colors" do
      squares = []
      0.upto(100) do |level|
        g = GameState.new
        g.level = level
        0.upto(9) do |color|
          squares << [Square.new(color,g), 0,0,1]
        end
      end
      test_window = TestWindow.new(squares,2) do |current_widget, current_time|

      end
      test_window.show
    end
  end
end

