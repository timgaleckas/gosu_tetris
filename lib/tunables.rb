class Tunables
  @slide_buffer = 5
  @down_speed = 9
  @rotate_repeat = 8

  class << self
    attr_accessor :down_speed
    attr_accessor :rotate_repeat
    attr_accessor :slide_buffer

    def speed_for_level(level)
      level
    end
  end
end
