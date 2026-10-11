# Builds believable stacks for the promo scenes by dropping real pieces where a simple
# player would: low, flat and without covered holes. Plain Ruby, so find_seed.rb can
# search seeds under MRI and scenes.rb can build the same stacks in DragonRuby.
module Stacker
  # Each distinct rotation's cells as [column, row] offsets from its top-left.
  def self.shapes(piece)
    (0..3).map do |turns|
      rotated = piece
      turns.times { rotated = rotated.rotated_right }
      cells = rotated.squares_with_coordinates(0, 0).map { |(_, x, y)| [x.div(Square.width), y.div(Square.height)] }
      left = cells.map(&:first).min
      top = cells.map(&:last).min
      cells.map { |x, y| [x - left, y - top] }
    end.uniq
  end

  # Drops count random pieces into rows (the board's rows of squares or nils), each at
  # its best-scoring spot. well_col stays empty; no column grows past max_height.
  def self.stack(rows, state, count, rng, well_col: nil, max_height: rows.size)
    columns = rows[0].size
    count.times do
      piece = rng.sample(Piece::ALL)
      best = nil
      shapes(piece).each do |cells|
        width = cells.map(&:first).max + 1
        (0..columns - width).each do |column|
          next if well_col && cells.any? { |x, _| x + column == well_col }
          placed = _drop(rows, cells, column)
          next unless placed
          score = _score(rows, placed, well_col, max_height, rng)
          best = [score, placed] if score && (!best || score < best[0])
        end
      end
      next unless best
      color = piece.instance_variable_get(:@color_index)
      best[1].each { |x, y| rows[y][x] = Square.new(color, state) }
    end
  end

  # The cells' board positions once dropped in at column, or nil if they don't fit.
  def self._drop(rows, cells, column)
    row = -4
    row += 1 while cells.all? do |x, y|
      below = row + y + 1
      below < rows.size && (below < 0 || !rows[below][x + column])
    end
    return nil if cells.any? { |_, y| row + y < 0 }
    cells.map { |x, y| [x + column, row + y] }
  end

  # Lower is better: low, few covered holes, flat. nil if it grows too tall.
  def self._score(rows, placed, well_col, max_height, rng)
    filled = rows.map { |row| row.map { |square| !!square } }
    placed.each { |x, y| filled[y][x] = true }
    columns = (0...rows[0].size).to_a - [well_col]
    tops = columns.map { |x| filled.index { |row| row[x] } || rows.size }
    heights = tops.map { |top| rows.size - top }
    holes = columns.zip(tops).to_a.sum { |x, top| (top...rows.size).count { |y| !filled[y][x] } }
    bumpiness = heights.each_cons(2).to_a.sum { |a, b| (a - b).abs }
    # A little noise breaks ties; drawn for every spot so the seeds stay stable.
    score = heights.sum * 0.5 + holes * 6 + bumpiness * 0.4 + rng.rand(10) * 0.05
    heights.max > max_height ? nil : score
  end
end
