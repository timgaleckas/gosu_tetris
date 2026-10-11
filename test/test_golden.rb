require_relative './test_helper'
require_relative './support/simulation'

# Golden-master tests: each scenario plays a seeded, scripted session and compares
# the frame-by-frame trace with test/golden/<name>.trace. They pin the gameplay
# (timings, kicks, gravity, cascades, scoring, sounds) so refactors and ports can
# be checked against the original feel. Regenerate with UPDATE_GOLDEN=1 only when
# a behavior change is intended, and review the diff.
describe "golden master" do
  GOLDEN_DIR = File.expand_path('golden', __dir__)

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
      rng = Random.new(seed)
      rows = board._rows
      (rows.size - n...rows.size).each do |r|
        rows[r].each_index { |c| rows[r][c] = rng.rand < 0.75 ? Square.new(rng.rand(7), nil) : nil }
      end
    end
  end

  # name => [seed, game state options, board setup, sounds the trace must include]
  SCENARIOS = {
    'classic_well'       => [11, CLASSIC, well(12), %w[SFX_LevelUp SFX_SpecialTetris]],
    'classic_fast'       => [1, CLASSIC.merge(speed_level: 7), nil, %w[SFX_PieceLockdown]],
    'next_default_lose'  => [1, {}, nil, %w[SFX_PieceLockdown]],
    'next_default_win'   => [6, {}, nil, %w[SFX_SpecialLineClearSingle]],
    'next_marathon'      => [6, { marathon: true }, nil, %w[SFX_SpecialLineClearSingle]],
    'gravity_well'       => [15, { junk_level: 0 }, well(12), %w[SFX_LevelUp SFX_SpecialTetris]],
    'gravity_scatter_a'  => [6, { junk_level: 0 }, scatter(10, 6), %w[SFX_SpecialLineClearTriple]],
    'gravity_scatter_b'  => [15, { junk_level: 0 }, scatter(10, 15), %w[SFX_SpecialLineClearDouble]],
    'gravity_drop_rows'  => [6, { junk_level: 0, drop_cleared_rows: true }, scatter(10, 6), []]
  }.freeze

  SCENARIOS.each do |name, (seed, options, setup, expected_sounds)|
    it "plays #{name} the same way" do
      trace = Simulation.new(seed: seed, frames: 6000, game_state_options: options, &setup).run.trace
      path = File.join(GOLDEN_DIR, "#{name}.trace")

      if ENV['UPDATE_GOLDEN'] || !File.exist?(path)
        FileUtils.mkdir_p(GOLDEN_DIR)
        File.write(path, trace.join("\n") + "\n")
      end

      sounds_heard = trace.grep(/ sounds=/).flat_map { |line| line[/ sounds=(\S+)/, 1].split(',') }
      _(expected_sounds - sounds_heard).must_be_empty

      expected = File.read(path).split("\n")
      actual = trace.join("\n").split("\n")
      mismatch = expected.zip(actual).index { |e, a| e != a } || (expected.size != actual.size && [expected.size, actual.size].min)
      if mismatch
        context = (mismatch - 3...mismatch).select { |i| i >= 0 }.map { |i| "  #{expected[i]}" }
        flunk <<~MSG
          #{name} diverges from #{File.basename(path)} at line #{mismatch + 1}:
          #{context.join("\n")}
          - expected: #{expected[mismatch].inspect}
          + actual:   #{actual[mismatch].inspect}
        MSG
      end
    end
  end

  it "has a junk-clearing win that marathon mode plays past" do
    outcome = ->(name) { File.read(File.join(GOLDEN_DIR, "#{name}.trace")).lines.last.strip }
    _(outcome['next_default_win']).must_equal 'end won=true lost=false'
    _(outcome['next_marathon']).wont_equal 'end won=true lost=false'
  end

  it "has a scenario where cascades earn praise" do
    praise = %w[gravity_scatter_a gravity_scatter_b].sum do |name|
      File.read(File.join(GOLDEN_DIR, "#{name}.trace")).scan(/VO_[A-Z]+/).size
    end
    _(praise).must_be :>, 0
  end
end
