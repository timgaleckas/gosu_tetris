class KeyMap
  class << self
    def self.pressable(method)
      define_method("#{method}_pressed?") do
        Array(send(method)).any?{|button|Gosu.button_down?(button)}
      end
    end

    pressable def down
      [Gosu::KbDown, Gosu::Gp0Down]
    end

    pressable def left
      [Gosu::KbLeft, Gosu::Gp0Left]
    end

    pressable def right
      [Gosu::KbRight, Gosu::Gp0Right]
    end

    pressable def rotate_right
      [Gosu::KbUp, Gosu::Gp0Button1]
    end

    pressable def rotate_left
      [Gosu::Gp0Button0]
    end

    pressable def pause
      [Gosu::KbP, Gosu::Gp0Button6]
    end
  end
end
