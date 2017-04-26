require_relative './test_helper'

class TestWindow < Gosu::Window
  attr_accessor :widgets

  def initialize(width, height, widgets, time)
    super(width, height)
    @widgets = widgets
    @time = time
  end

  def draw
    Gosu.draw_rect(0,0,width,height,Gosu::Color::WHITE)
    line_x = (width % Square.width) / 2
    while line_x < width
      Gosu.draw_line(line_x,0,Gosu::Color::BLACK,line_x,height,Gosu::Color::BLACK,1)
      line_x += Square.width
    end
    line_y = (height % Square.height) / 2
    while line_y < height
      Gosu.draw_line(0,line_y,Gosu::Color::BLACK,width,line_y,Gosu::Color::BLACK,1)
      line_y += Square.height
    end
    @widgets.each do |(widget, *args)|
      widget.draw(*args)
    end
  end

  def update
    @time -= 1
    close if @time < 0
  end
end

describe NextPiece do
  it "displays correctly" do
    Piece::ALL.each do |piece|
      next_piece = NextPiece.new(200,200, piece)
      TestWindow.new(200,200,[next_piece], 100).show
    end
  end
end

