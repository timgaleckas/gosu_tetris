class Sprites
  SQUARE_WIDTH = 30
  SQUARE_HEIGHT = 30

  SPRITE_SHEET = Gosu::Image.new('./assets/blocks.png')
  SQUARES = 0.upto(9).map do |row|
    0.upto(4).map do |column|
      SPRITE_SHEET.subimage(SQUARE_WIDTH*column,SQUARE_HEIGHT*row,SQUARE_WIDTH,SQUARE_HEIGHT)
    end
  end

  STITCHES = Gosu::Image.new('./assets/stitches.png')

  PAUSE_ICON = Gosu::Image.new('./assets/Pause.png')
end

