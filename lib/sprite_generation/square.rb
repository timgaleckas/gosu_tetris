class SpriteGeneration::Square
  class << self
    include Magick
    def draw_square(row,column,color,image)
      x = column * Square.width
      y = row * Square.height
      gc = Magick::Draw.new
      gc.stroke = color
      gc.fill = color
      gc.rectangle(x + 1, y + 1, x + Square.width - 2, y + Square.height - 2 )
      gc.draw(image)
    end

    def generate_sprite_sheet
      squares_wide = 7
      squares_high = 10
      image = Image.new(::Square.width*squares_wide,::Square.height*squares_high) { self.background_color = "black" }
      [
        ["cyan","blue","magenta","gray","green","yellow","red"],
        ["cyan","blue","magenta","gray","green","yellow","red"],
        ["cyan","blue","magenta","gray","green","yellow","red"],
        ["cyan","blue","magenta","gray","green","yellow","red"],
        ["cyan","blue","magenta","gray","green","yellow","red"],
        ["cyan","blue","magenta","gray","green","yellow","red"],
        ["cyan","blue","magenta","gray","green","yellow","red"],
        ["cyan","blue","magenta","gray","green","yellow","red"],
        ["cyan","blue","magenta","gray","green","yellow","red"],
        ["cyan","blue","magenta","gray","green","yellow","red"]
      ].each_with_index do |row, row_index|
        row.each_with_index do |color, column_index|
          draw_square(row_index,column_index,color,image)
        end
      end

      Gosu::Image.new(image)
    end

    def write_file
      generate_sprite_sheet.save(App.asset_root / 'blocks.png')
    end
  end
end
