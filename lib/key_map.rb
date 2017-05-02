class KeyMap
  class << self
    def self.pressable(method)
      define_method("#{method}_pressed?") do
        Array(send(method)).any?{|button|Gosu.button_down?(button)}
      end
    end

    pressable def down
      [Gosu::KB_DOWN, Gosu::GP_0_DOWN]
    end

    pressable def left
      [Gosu::KB_LEFT, Gosu::GP_0_LEFT]
    end

    pressable def right
      [Gosu::KB_RIGHT, Gosu::GP_0_RIGHT]
    end

    pressable def rotate_right
      [Gosu::KB_UP, Gosu::GP_0_BUTTON_1]
    end

    pressable def rotate_left
      [Gosu::GP_0_BUTTON_0]
    end

    pressable def pause
      [Gosu::KB_P, Gosu::GP_0_BUTTON_6]
    end
  end
end
