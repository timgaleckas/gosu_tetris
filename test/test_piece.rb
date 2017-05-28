require_relative './test_helper'

describe Piece do
  def t
    Piece.new([
      [nil, 1],
      [1,   1]
    ])
  end

  describe "#rotated_left" do
    it "gives you a new piece" do
      piece = t
      rotated_piece = t.rotated_left
      rotated_piece.class.must_equal Piece
      rotated_piece.wont_equal piece
    end
  end

  describe "#rotated_right" do
    it "gives you a new piece" do
      piece = t
      rotated_piece = t.rotated_right
      rotated_piece.class.must_equal Piece
      rotated_piece.wont_equal piece
    end
  end

  describe "#squares_with_coordinates" do
    it "responds correctly for O" do
      Piece::O.squares_with_coordinates(0,0).map{|r| r[1..2]}.sort.must_equal [
        [30, 30], [30, 60],
        [60, 30], [60, 60]
      ].sort
    end

    it "responds correctly for T" do
      swc = Piece::T.squares_with_coordinates(0,0)

      swc.map{|r| r[1..2]}.sort.must_equal [
                 [30, 0],
        [0, 30], [30, 30], [60, 30]
      ].sort

      swc[2][0].up.must_equal    swc[0][0]
      swc[2][0].right.must_equal swc[3][0]
      swc[2][0].left.must_equal  swc[1][0]
    end

    it "responds correctly for J" do
      swc = Piece::J.squares_with_coordinates(0,0)

      swc.map{|r| r[1..2]}.sort.must_equal [
        [0, 0],
        [0, 30], [30, 30], [60, 30]
      ].sort

      swc[1][0].up.must_equal    swc[0][0]
      swc[1][0].right.must_equal swc[2][0]
      swc[2][0].right.must_equal swc[3][0]
    end
  end
end
