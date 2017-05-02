class Sprites
  SQUARE_WIDTH = 30
  SQUARE_HEIGHT = 30
  STITCH_WIDTH = 6

  HORIZONTAL_STITCHES_SHEET = Gosu::Image.new(App.asset_root / 'horizontal_stitches.png')
  SQUARES_SHEET = Gosu::Image.new(App.asset_root / 'blocks.png')
  VERTICAL_STITCHES_SHEET = Gosu::Image.new(App.asset_root / 'vertical_stitches.png')

  SQUARES = 0.upto(SQUARES_SHEET.height / SQUARE_HEIGHT).map do |row|
    0.upto(SQUARES_SHEET.width / SQUARE_WIDTH).map do |column|
      SQUARES_SHEET.subimage(SQUARE_WIDTH*column,SQUARE_HEIGHT*row,SQUARE_WIDTH,SQUARE_HEIGHT)
    end
  end

  HORIZONTAL_STITCHES = 0.upto(HORIZONTAL_STITCHES_SHEET.height / STITCH_WIDTH).map do |row|
    0.upto(HORIZONTAL_STITCHES_SHEET.width / (SQUARE_HEIGHT - 2)).map do |column|
      HORIZONTAL_STITCHES_SHEET.subimage((SQUARE_WIDTH-2)*column,STITCH_WIDTH*row,SQUARE_WIDTH-2,STITCH_WIDTH)
    end
  end

  VERTICAL_STITCHES = 0.upto(VERTICAL_STITCHES_SHEET.height / (SQUARE_HEIGHT - 2)).map do |row|
    0.upto(VERTICAL_STITCHES_SHEET.width / STITCH_WIDTH).map do |column|
      VERTICAL_STITCHES_SHEET.subimage(STITCH_WIDTH*column,(SQUARE_HEIGHT-2)*row,STITCH_WIDTH,SQUARE_HEIGHT-2)
    end
  end

  PAUSE_ICON = Gosu::Image.new(App.asset_root / 'Pause.png')
end

