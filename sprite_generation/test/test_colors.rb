require_relative './test_helper'

describe 'color picker' do
  describe "do it" do
    class ColorPicker < Gosu::Window
      def initialize(colors)
        @dim = (colors.size ** Rational(1,2)).ceil
        super(@dim*30, @dim*30)
        @colors = colors
      end

      def draw
        (0...@dim).each do |column|
          (0...@dim).each do |row|
            Gosu.draw_rect(column*30,row*30,30,30,1.0,0,@colors[3])
          end
        end
      end
    end

    ColorPicker.new(Colors::COLORS).show
  end
end

