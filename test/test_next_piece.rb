require_relative './test_helper'

describe NextPiece do
  it "displays correctly" do
    widgets = Piece::ALL.map do |piece|
      [piece, piece = piece.rotated_right, piece = piece.rotated_right, piece.rotated_right]
    end.flatten.map do |piece|
      NextPiece.new(200,200,nil,piece)
    end
    TestWindow.new(widgets, 25).show
  end
end

