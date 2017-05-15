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
      [Gosu::KbDown, Gosu::Gp0Down]
    end
    pressable :down

    def left
      [Gosu::KbLeft, Gosu::Gp0Left]
    end
    pressable :left, Tunables.slide_repeat

    def right
      [Gosu::KbRight, Gosu::Gp0Right]
    end
    pressable :right, Tunables.slide_repeat

    def rotate_right
      [Gosu::KbUp, Gosu::Gp0Button1]
    end
    pressable :rotate_right, Tunables.rotate_repeat

    def rotate_left
      [Gosu::Gp0Button0]
    end
    pressable :rotate_left, Tunables.rotate_repeat

    def pause
      [Gosu::KbP, Gosu::Gp0Button6]
    end
    pressable :pause
  end
end
