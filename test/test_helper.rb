require 'minitest/autorun'
require_relative '../lib/app'

class TestWindow < Gosu::Window
  def initialize(widgets, time_between_widgets, magnification=1, &block)
    super(1,1)
    @widgets = widgets
    @time_between_widgets = time_between_widgets
    @current_time = 0
    @callback = block
    @magnification = magnification
  end

  def draw
    current_widget, *args = current_widget_and_args
    self.width = current_widget ? (current_widget.width * @magnification) + 4 : 1
    self.height = current_widget ? (current_widget.height * @magnification) + 4 : 1
    Gosu.draw_rect(0,0,width,height,Gosu::Color::AQUA)
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
    Gosu.translate(2,2) do
      Gosu.scale(@magnification) do
        current_widget_and_args && current_widget.draw(*args)
      end
    end
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

def sleep_to_see_test
  sleep ENV['FRAME_PAUSE'].to_f / 1000 if ENV['FRAME_PAUSE']
end
