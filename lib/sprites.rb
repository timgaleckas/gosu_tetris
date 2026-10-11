class Sprites
  SQUARE_WIDTH = 30
  SQUARE_HEIGHT = 30

  SQUARES = Gosu::Image.load_tiles((App.asset_root / 'blocks.png').to_s, SQUARE_WIDTH, SQUARE_HEIGHT, :tileable => true)
  BORDERS = Gosu::Image.load_tiles((App.asset_root / 'borders.png').to_s, SQUARE_WIDTH, SQUARE_HEIGHT, :tileable => true)

  PAUSE_ICON = Gosu::Image.new((App.asset_root / 'Pause.png').to_s)

  MOUSE_CURSOR = Gosu::Image.new((App.asset_root / 'pointer.png').to_s)
end

