# Drawing for the rules' objects; mirrors lib/views (SquareView, BoardView, NextPiece).
module Views
  BLOCKS = 'assets/blocks.png'.freeze     # 8 colors across, one row per level
  BORDERS = 'assets/borders.png'.freeze   # 16 border combinations across
  SIZE = Square::SIZE

  # A square's sprite and borders at (x, y), scaled to size, shrinking about its
  # center as it disappears and offset upward while it drops.
  def self.square(canvas, square, x, y, size = SIZE)
    scale = size.to_f / SIZE
    shrink = 1 - (square.disappearing.to_f / Square::DISAPPEAR_LIMIT)
    half = size / 2.0
    drawn = size * shrink
    left = x + half - half * shrink
    top = y + half - (square.dropping * scale + half) * shrink

    level_index = (square.game_state ? square.game_state.speed_level : 0) % 10
    canvas.sprite(left, top, drawn, drawn, BLOCKS,
                  tile_x: square.color_index * SIZE, tile_y: level_index * SIZE, tile_w: SIZE, tile_h: SIZE)

    border_index = 0
    [square.left, square.right, square.up, square.down].each do |neighbor|
      joined = !square.permalocked? && neighbor && square.color_index == neighbor.color_index
      border_index = border_index * 2 + (joined ? 0 : 1)
    end
    canvas.sprite(left, top, drawn, drawn, BORDERS,
                  tile_x: border_index * SIZE, tile_y: 0, tile_w: SIZE, tile_h: SIZE)
  end

  # The board, clipped to its own render target.
  def self.board(outputs, board)
    canvas = Canvas.new(outputs[:board], board.width, board.height)
    board.each_settled_square do |square, x, y|
      square(canvas, square, board.x + x, board.y + y)
    end
    board.falling_squares.each do |(square, x, y)|
      square(canvas, square, board.x + x, board.y + y)
    end
  end

  # The upcoming piece at half size in a 100x100 box at (x, y).
  def self.next_piece(canvas, piece, x, y)
    piece.squares_with_coordinates(40, 10).each do |(square, sx, sy)|
      square(canvas, square, x + sx / 2.0, y + sy / 2.0, SIZE / 2)
    end
  end
end
