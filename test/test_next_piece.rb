require_relative './test_helper'

describe NextPiece do
  it "displays correctly" do
    widgets = Piece::ALL.map do |piece|
      [piece, piece = piece.rotated_right, piece = piece.rotated_right, piece.rotated_right]
    end.flatten.map do |piece|
      NextPiece.new(200,200,nil,piece)
    end
    w = TestWindow.new(widgets, 1) do |current_widget, current_time|
      sleep_to_see_test
    end
    w.show
  end
end

