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
    it "responds correctly for Q" do
      Piece::Q.squares_with_coordinates(0,0).map{|r| r[1..2]}.sort.must_equal [
        [30,  60], [60, 60],
        [30,  90], [60, 90]
      ].sort
    end

    it "responds correctly for T" do
      Piece::T.squares_with_coordinates(0,0).map{|r| r[1..2]}.sort.must_equal [
        [30,  60], [60, 60], [90, 60],
                   [60, 90]
      ].sort
    end
  end
end
