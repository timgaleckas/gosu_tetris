require_relative './test_helper'

describe Piece do
  def t
    Piece.new([
      [nil, 1,   nil],
      [1,   1,   1  ]
    ])
  end

  describe "#rotated_left" do
    it "gives you a new piece" do
      t.rotated_left.class.must_equal Piece
    end

    it "is rotated properly" do
      t.rotated_left._squares.must_equal([
        [nil, 1],
        [1,   1],
        [nil, 1]
      ])
    end

    it "doesn't allow mutating the original piece" do
      p = t
      p1 = t.rotated_left
      p1._squares[0][0] = 2

      p1._squares.must_equal([
        [2,   1],
        [1,   1],
        [nil, 1]
      ])

      p._squares.must_equal([
        [nil, 1,   nil],
        [1,   1,   1  ]
      ])
    end
  end

  describe "#rotated_right" do
    it "gives you a new piece" do
      t.rotated_right.class.must_equal Piece
    end

    it "is rotated properly" do
      t.rotated_right._squares.must_equal([
        [1, nil],
        [1, 1  ],
        [1, nil]
      ])
    end

    it "doesn't allow mutating the original piece" do
      p = t
      p1 = t.rotated_right
      p1._squares[0][0] = 2

      p1._squares.must_equal([
        [2, nil],
        [1, 1  ],
        [1, nil]
      ])

      p._squares.must_equal([
        [nil, 1,   nil],
        [1,   1,   1  ]
      ])
    end
  end

  describe "#squares_high" do
    it "should report squares high correctly" do
      t.squares_high.must_equal 2
    end
  end

  describe "#squares_wide" do
    it "should report squares wide correctly" do
      t.squares_wide.must_equal 3
    end
  end
end
