# Finds Stacker seeds that build a clean Classic stack: no covered holes, at least four
# rows full apart from the well, 8 to 11 rows tall. scenes.rb uses one of them.
#   ruby tools/promo/find_seed.rb
require_relative '../../lib/core'
require_relative 'stacker'

ROWS = 20
COLUMNS = 9
WELL = COLUMNS - 1

found = []
(1..3000).each do |seed|
  [22, 24, 26].each do |count|
    rows = Array.new(ROWS) { [nil] * COLUMNS }
    Stacker.stack(rows, nil, count, Rng.new(seed), well_col: WELL, max_height: 11)
    full = rows.count { |row| row[0...WELL].all? }
    holes = (0...WELL).sum do |x|
      top = rows.index { |row| row[x] }
      top ? (top...ROWS).count { |y| !rows[y][x] } : 0
    end
    height = ROWS - (rows.index { |row| row.any? } || ROWS)
    found << { seed: seed, pieces: count, full_rows: full, height: height } if holes == 0 && full >= 4 && height.between?(8, 11)
  end
end
found.first(10).each { |f| p f }
puts "#{found.size} found"
