require_relative './test_helper'

describe Square do
  it "can doubly link left" do
    r = Square.new(0,nil)
    l1 = Square.new(0,nil)
    l2 = Square.new(0,nil)
    r.left = l1
    _(r.left).must_equal l1
    _(l1.right).must_equal r

    r.left = l2
    _(r.left).must_equal l2
    assert_nil l1.right
    _(l2.right).must_equal r
  end
  it "can doubly link right" do
    l = Square.new(0,nil)
    r1 = Square.new(0,nil)
    r2 = Square.new(0,nil)
    l.right = r1
    _(l.right).must_equal r1
    _(r1.left).must_equal l

    l.right = r2
    _(l.right).must_equal r2
    assert_nil r1.left
    _(r2.left).must_equal l
  end
  it "can doubly link up" do
    d = Square.new(0,nil)
    u1 = Square.new(0,nil)
    u2 = Square.new(0,nil)
    d.up = u1
    _(d.up).must_equal u1
    _(u1.down).must_equal d

    d.up = u2
    _(d.up).must_equal u2
    assert_nil u1.down
    _(u2.down).must_equal d
  end
  it "can doubly link down" do
    u = Square.new(0,nil)
    d1 = Square.new(0,nil)
    d2 = Square.new(0,nil)
    u.down = d1
    _(u.down).must_equal d1
    _(d1.up).must_equal u

    u.down = d2
    _(u.down).must_equal d2
    assert_nil d1.up
    _(d2.up).must_equal u
  end

  describe "drawing" do
    it "can be visually inspected" do
      s = Square.new(0, nil)

      s.right = s
      s.down = s

      test_window = TestWindow.new([[s,0,0,1]],200,4) do |current_widget, current_time|
      end
      test_window.show
    end

    it "can be drawn for 11 levels and 7 colors" do
      squares = []
      0.upto(11) do |level|
        g = GameState.new
        g.speed_level = level
        0.upto(6) do |color|
          squares << [Square.new(color,g), 0,0,1]
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
        squares << [s,0,0,0]
        s = s.dup
        s.disappearing += 1
      end

      test_window = TestWindow.new(squares,2) do |current_widget, current_time|
        _(current_widget.disappearing?).must_equal true
      end
      test_window.show
    end
  end
end

