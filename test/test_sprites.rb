require_relative './test_helper'

describe Sprites do
  describe "drawing" do
    it "can be visually inspected" do
      s = Sprites::SQUARES.first

      test_window = TestWindow.new([[s,0,0,1]],200,4) do |current_widget, current_time|
      end
      test_window.show
    end
  end
end
