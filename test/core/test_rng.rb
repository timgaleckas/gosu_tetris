require_relative '../core_helper'

# These values are what every Ruby must produce for the golden traces to replay.
describe Rng do
  it "produces the same sequence for a seed" do
    rng = Rng.new(1)
    _(Array.new(8) { rng.rand(1000) }).must_equal [233, 504, 482, 210, 29, 932, 299, 943]
  end

  it "samples from arrays" do
    rng = Rng.new(42)
    _(Array.new(6) { rng.sample(%w[a b c d e f g]) }.join).must_equal "adgafe"
  end

  it "replaces a zero seed" do
    _(Rng.new(0).rand(1_000_000)).must_be :>, 0
  end
end
