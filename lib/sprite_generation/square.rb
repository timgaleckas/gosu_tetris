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
      gc.rectangle(x, y, x + Square.width, y + Square.height)
      gc.draw(image)
    end

    def draw_borders(row,column,l,r,u,d,image)
      x = column * Square.width
      y = row * Square.height
      x2 = x + Square.width - 1
      y2 = y + Square.height - 1
      bd = Magick::Draw.new
      bd.stroke = 'black'
      bd.line(x,  y,  x,  y2 ) if l
      bd.line(x2, y,  x2, y2 ) if r
      bd.line(x,  y,  x2, y  ) if u
      bd.line(x,  y2, x2, y2 ) if d
      bd.draw(image) if l || r || u || d
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

    def generate_border_sprite_sheet
      image = Image.new(::Square.width*16,::Square.height) { self.background_color = "transparent" }

      0.upto(15) do |i|
        l,r,u,d = ("%0.4b" % i).chars.map{|c|c=="1"}
        draw_borders(0,i,l,r,u,d,image)
      end

      Gosu::Image.new(image)
    end

    def write_files
      generate_sprite_sheet.save(App.asset_root / 'blocks.png')
      generate_border_sprite_sheet.save(App.asset_root / 'borders.png')
    end
  end
end
