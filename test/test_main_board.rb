require_relative './test_helper'

describe MainBoard do
  def main_board
    MainBoard.new(0,0,154,310)
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
end

