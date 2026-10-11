# Seeded random numbers that come out the same on every Ruby (MRI, mruby/DragonRuby),
# so a seed replays the same game anywhere. xorshift32, kept within 32 bits.
class Rng
  MASK = 0xFFFFFFFF

  def initialize(seed = Kernel.rand(MASK))
    @state = seed & MASK
    @state = 0x9E3779B9 if @state == 0
    4.times { _next }
  end

  # Integer in 0...n.
  def rand(n)
    _next % n
  end

  def sample(array)
    array[rand(array.size)]
  end

  def _next
    x = @state
    x ^= (x << 13) & MASK
    x ^= x >> 17
    x ^= (x << 5) & MASK
    @state = x
  end
end
