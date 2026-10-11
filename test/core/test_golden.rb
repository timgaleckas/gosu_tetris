require_relative '../core_helper'
require_relative './simulation'
require_relative './scenarios'

# Golden-master tests: each scenario plays a seeded, scripted session and compares
# the frame-by-frame trace with test/core/golden/<name>.trace. They pin the gameplay
# (timings, kicks, gravity, cascades, scoring, sounds) so refactors and ports can
# be checked against the original feel. Regenerate with UPDATE_GOLDEN=1 only when
# a behavior change is intended, and review the diff.
describe "golden master" do
  GOLDEN_DIR = File.expand_path('golden', __dir__)

  GoldenScenarios::ALL.each do |name, (seed, options, setup, expected_sounds)|
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
