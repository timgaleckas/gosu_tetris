class SpriteGeneration::Square
  SQUARES_WIDE = 7
  SQUARES_HIGH = 10

  COLORS = [
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
  ]

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

    def draw_vertical_stitches(row,column,color,image)
      x = column * Square.stitch_width
      y = row * (Square.height-2)
      gc = Magick::Draw.new
      gc.stroke = color
      gc.fill = color
      gc.rectangle(x, y, x + Square.stitch_width, y + Square.height - 2 )
      gc.draw(image)
    end

    def draw_horizontal_stitches(row,column,color,image)
      x = column * (Square.width-2)
      y = row * Square.stitch_width
      gc = Magick::Draw.new
      gc.stroke = color
      gc.fill = color
      gc.rectangle(x, y, x + Square.width - 2, y + Square.stitch_width )
      gc.draw(image)
    end

    def generate_sprite_sheet
      image = Image.new(::Square.width*SQUARES_WIDE,::Square.height*SQUARES_HIGH) { self.background_color = "black" }
      COLORS.each_with_index do |row, row_index|
        row.each_with_index do |color, column_index|
          draw_square(row_index,column_index,color,image)
        end
      end

      Gosu::Image.new(image)
    end

    def generate_horizontal_stitches_sprite_sheet
      image = Image.new((Square.width - 2)*SQUARES_WIDE, Square.stitch_width*SQUARES_HIGH)
      COLORS.each_with_index do |row, row_index|
        row.each_with_index do |color, column_index|
          draw_horizontal_stitches(row_index,column_index,color,image)
        end
      end

      Gosu::Image.new(image)
    end

    def generate_vertical_stitches_sprite_sheet
      image = Image.new(Square.stitch_width*SQUARES_WIDE, (Square.height-2)*SQUARES_HIGH)
      COLORS.each_with_index do |row, row_index|
        row.each_with_index do |color, column_index|
          draw_vertical_stitches(row_index,column_index,color,image)
        end
      end

      Gosu::Image.new(image)
    end

    def write_files
      generate_sprite_sheet.save(App.asset_root / 'blocks.png')
      generate_vertical_stitches_sprite_sheet.save(App.asset_root / 'vertical_stitches.png')
      generate_horizontal_stitches_sprite_sheet.save(App.asset_root / 'horizontal_stitches.png')
    end
  end
end
