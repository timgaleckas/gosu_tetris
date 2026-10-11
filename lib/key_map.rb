class KeyMap
  class << self
    def self.pressable(method, repeat=nil)
      define_method("#{method}_pressed?") do
        if repeat
          @pressed_for ||= {}
          @pressed_for[method] ||= -1
          if Array(send(method)).any?{|button|Gosu.button_down?(button)}
            @pressed_for[method] += 1
          else
            @pressed_for[method]=-1
          end
          @pressed_for[method] % repeat == 0
        else
          Array(send(method)).any?{|button|Gosu.button_down?(button)}
        end
      end
    end

    def down
      [Gosu::KB_DOWN, Gosu::GP_0_DOWN]
    end
    pressable :down

    def left
      [Gosu::KB_LEFT, Gosu::GP_0_LEFT]
    end
    pressable :left, Tunables.slide_repeat

    def right
      [Gosu::KB_RIGHT, Gosu::GP_0_RIGHT]
    end
    pressable :right, Tunables.slide_repeat

    def rotate_right
      [Gosu::KB_UP, Gosu::GP_0_BUTTON_1]
    end
    pressable :rotate_right, Tunables.rotate_repeat

    def rotate_left
      [Gosu::GP_0_BUTTON_0]
    end
    pressable :rotate_left, Tunables.rotate_repeat

    def pause
      [Gosu::KB_P, Gosu::GP_0_BUTTON_6]
    end
    pressable :pause
  end
end
