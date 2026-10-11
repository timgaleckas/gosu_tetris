# The scripted sessions recorded in golden/<name>.trace. Plain Ruby so both the
# MRI tests (test_golden.rb) and DragonRuby (test/dragonruby/tests.rb) can run them.
module GoldenScenarios
  CLASSIC = { junk_level: 0, multicolor: false, drop_cleared_rows: true, gravity: false }.freeze

  # Bottom n rows full except one column.
  def self.well(n, col: 4)
    ->(board) do
      rows = board._rows
      (rows.size - n...rows.size).each do |r|
        rows[r].each_index { |c| rows[r][c] = c == col ? nil : Square.new(r % 7, nil) }
      end
    end
  end

  # Bottom n rows randomly filled with mixed colors.
  def self.scatter(n, seed)
    ->(board) do
      rng = Rng.new(seed)
      rows = board._rows
      (rows.size - n...rows.size).each do |r|
        rows[r].each_index { |c| rows[r][c] = rng.rand(4) < 3 ? Square.new(rng.rand(7), nil) : nil }
      end
    end
  end

  # name => [seed, game state options, board setup, sounds the trace must include]
  ALL = {
    'classic_well'       => [171, CLASSIC, well(12, col: 5), %w[SFX_LevelUp SFX_SpecialTetris]],
    'classic_fast'       => [1, CLASSIC.merge(speed_level: 7), nil, %w[SFX_PieceLockdown]],
    'next_default_lose'  => [1, {}, nil, %w[SFX_PieceLockdown]],
    'next_default_win'   => [50, {}, nil, %w[SFX_SpecialLineClearSingle]],
    'next_marathon'      => [50, { marathon: true }, nil, %w[SFX_SpecialLineClearSingle]],
    'gravity_well'       => [157, { junk_level: 0 }, well(14, col: 5), %w[SFX_LevelUp SFX_SpecialTetris]],
    'gravity_scatter_a'  => [1, { junk_level: 0 }, scatter(10, 1), %w[SFX_SpecialLineClearTriple]],
    'gravity_scatter_b'  => [11, { junk_level: 0 }, scatter(10, 11), %w[SFX_SpecialLineClearDouble]],
    'gravity_drop_rows'  => [1, { junk_level: 0, drop_cleared_rows: true }, scatter(10, 1), []]
  }.freeze
end
