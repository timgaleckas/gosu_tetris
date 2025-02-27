class Tunables
  @slide_buffer = 5
  @down_speed = 9
  @slide_repeat = 8
  @rotate_repeat = 4611686018427387903
  @lock_delay = 15
  @drop_rate = 10

  class << self
    attr_accessor :down_speed
    attr_accessor :rotate_repeat
    attr_accessor :slide_buffer
    attr_accessor :slide_repeat
    attr_accessor :lock_delay
    attr_accessor :drop_rate

    def speed_for_level(level)
      1 + ((level - 1).to_f * 0.8)
    end
  end
end
