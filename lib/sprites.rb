class Sprites
  SQUARE_WIDTH = 30
  SQUARE_HEIGHT = 30

  SPRITE_SHEET = Gosu::Image.new(App.asset_root / 'blocks.png')
  SQUARES = 0.upto(SPRITE_SHEET.height / SQUARE_HEIGHT).map do |row|
    0.upto(SPRITE_SHEET.width / SQUARE_WIDTH).map do |column|
      SPRITE_SHEET.subimage(SQUARE_WIDTH*column,SQUARE_HEIGHT*row,SQUARE_WIDTH,SQUARE_HEIGHT)
    end
  end

  STITCHES = Gosu::Image.new(App.asset_root / 'stitches.png')

  PAUSE_ICON = Gosu::Image.new(App.asset_root / 'Pause.png')
end

