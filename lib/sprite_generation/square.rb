class SpriteGeneration::Square
  SQUARES_WIDE = 7
  SQUARES_HIGH = 10

  #http://www.perbang.dk/color+scheme/
  COLORS = [
    ["#9999FF","#B479F2","#8888AA","#888811","#667755","#558811","#5F3F7F"],
    ["#AFADD8","#8899AA","#7D79F2","#888811","#777755","#2E70BD","#885511"],
    ["#2EB1BD","#776655","#885511","#3F5A7F","#225599","#3D4B4C","#882211"],
    ["#2EBD8B","#228899","#775555","#3D4C47","#882211","#79E0F2","#FFEEFF"],
    ["#2EBD46","#229966","#775555","#3D4C3F","#881177","#881133","#D7DDD8"],
    ["#85BD2E","#339922","#775577","#464C3D","#771188","#441188","#DCF2DA"],
    ["#AAAA88","#A4A800","#888811","#559922","#665577","#CCAADD","#551188"],
    ["#BD962E","#779922","#886611","#555577","#664A00","#113388","#AA9988"],
    ["#BD622E","#7F763F","#A83D00","#555577","#116688","#883311","#FFBE99"],
    ["#FF99AA","#AA8888","#556677","#118877","#7F543F","#BD2E46","#116688"]
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
