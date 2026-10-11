# Drawing for the rules' objects: squares, the board and the next piece.
module Views
  SIZE = Square::SIZE

  # Each square's color by speed level (rows, repeating every 10) and color index.
  COLORS = [
    %w[9999FF B479F2 8888AA 888811 667755 558811 5F3F7F FFFFFF],
    %w[AFADD8 8899AA 7D79F2 888811 777755 2E70BD 885511 FFFFFF],
    %w[2EB1BD 776655 885511 3F5A7F 225599 3D4B4C 882211 FFFFFF],
    %w[2EBD8B 228899 775555 3D4C47 882211 79E0F2 FFEEFF FFFFFF],
    %w[2EBD46 229966 775555 3D4C3F 881177 881133 D7DDD8 FFFFFF],
    %w[85BD2E 339922 775577 464C3D 771188 441188 DCF2DA FFFFFF],
    %w[AAAA88 A4A800 888811 559922 665577 CCAADD 551188 FFFFFF],
    %w[BD962E 779922 886611 555577 664A00 113388 AA9988 FFFFFF],
    %w[BD622E 7F763F A83D00 555577 116688 883311 FFBE99 FFFFFF],
    %w[FF99AA AA8888 556677 118877 7F543F BD2E46 116688 FFFFFF]
  ].map { |row| row.map { |hex| [hex[0, 2].to_i(16), hex[2, 2].to_i(16), hex[4, 2].to_i(16)] } }
  BORDER = [0, 0, 0].freeze

  # A square at (x, y), scaled to size, shrinking about its center as it disappears and
  # offset upward while it drops. A black line marks each side not joined to a neighbor
  # of its color. Drawn as plain rectangles rather than from a sprite sheet, so scaling
  # up (as in fullscreen) can't bleed neighboring tiles into the seams.
  def self.square(canvas, square, x, y, size = SIZE)
    scale = size.to_f / SIZE
    shrink = 1 - (square.disappearing.to_f / Square::DISAPPEAR_LIMIT)
    half = size / 2.0
    drawn = size * shrink
    left = x + half - half * shrink
    top = y + half - (square.dropping * scale + half) * shrink

    level_index = (square.game_state ? square.game_state.speed_level : 0) % 10
    canvas.rect(left, top, drawn, drawn, COLORS[level_index][square.color_index])

    line = drawn / SIZE
    canvas.rect(left, top, line, drawn, BORDER) if _border?(square, square.left)
    canvas.rect(left + drawn - line, top, line, drawn, BORDER) if _border?(square, square.right)
    canvas.rect(left, top, drawn, line, BORDER) if _border?(square, square.up)
    canvas.rect(left, top + drawn - line, drawn, line, BORDER) if _border?(square, square.down)
  end

  def self._border?(square, neighbor)
    square.permalocked? || !neighbor || square.color_index != neighbor.color_index
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
