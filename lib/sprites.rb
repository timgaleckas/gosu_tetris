class Sprites
  SQUARE_WIDTH = 30
  SQUARE_HEIGHT = 30

  SQUARES = Gosu::Image.load_tiles(App.asset_root / 'blocks.png', SQUARE_WIDTH, SQUARE_HEIGHT, :tileable => true)
  BORDERS = Gosu::Image.load_tiles(App.asset_root / 'borders.png', SQUARE_WIDTH, SQUARE_HEIGHT, :tileable => true)

  PAUSE_ICON = Gosu::Image.new(App.asset_root / 'Pause.png')
end

