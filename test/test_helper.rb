require 'minitest/autorun'
require_relative '../lib/app'

class TestWindow < Gosu::Window
  def initialize(width, height, widgets, time_between_widgets, &block)
    super(width, height)
    @widgets = widgets
    @time_between_widgets = time_between_widgets
    @current_time = 0
    @callback = block
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
    current_widget, *args = current_widget_and_args
    current_widget_and_args && current_widget.draw(*args)
  end

  def current_widget_and_args
    @widgets[@current_time / @time_between_widgets]
  end

  def update
    @current_time += 1
    current_widget, *_ = current_widget_and_args
    if current_widget
      current_widget.update if current_widget.respond_to? :update
      if @callback
        @callback.call current_widget, @current_time
      end
    else
      close
    end
  end
end
