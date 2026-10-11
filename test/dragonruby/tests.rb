# The core's cross-engine checks, run inside DragonRuby: bin/dr test
# They replay the golden scenarios recorded under MRI and expect the same trace.
require 'lib/core.rb'
require 'test/core/simulation.rb'
require 'test/core/scenarios.rb'

def test_rng_sequence args, assert
  rng = Rng.new(1)
  assert.equal! Array.new(8) { rng.rand(1000) }, [233, 504, 482, 210, 29, 932, 299, 943]
end

GoldenScenarios::ALL.each do |name, (seed, options, setup, _expected_sounds)|
  Object.send(:define_method, "test_golden_#{name}") do |args, assert|
    expected = DR.read_file("test/core/golden/#{name}.trace").split("\n")
    actual = Simulation.new(seed: seed, frames: 6000, game_state_options: options, &setup).run.trace.join("\n").split("\n")
    mismatch = (0...[expected.size, actual.size].max).find { |i| expected[i] != actual[i] }
    if mismatch
      assert.equal! actual[mismatch], expected[mismatch], "#{name} diverges at line #{mismatch + 1}"
    else
      assert.ok!
    end
  end
end
