class Sprites
  SQUARE_WIDTH = 30
  SQUARE_HEIGHT = 30

  SPRITE_SHEET = Gosu::Image.new('./assets/blocks.png')
  SQUARES = 0.upto(4).map{|i|SPRITE_SHEET.subimage(SQUARE_WIDTH*i,0,SQUARE_WIDTH,SQUARE_HEIGHT)}
end

