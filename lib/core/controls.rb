# Turns held buttons into per-frame actions with the game's key repeat timing.
# input responds to held?(action) for :left, :right, :down, :rotate_right and :rotate_left.
class Controls
  # Frames between repeats while an action is held; nil means it acts every frame it's held.
  def self.repeat_for(action)
    case action
    when :left, :right
      Tunables.slide_repeat
    when :rotate_left, :rotate_right
      Tunables.rotate_repeat
    end
  end

  class NoInput
    def held?(_action)
      false
    end
  end

  def initialize(input = NoInput.new)
    @input = input
    @pressed_for = {}
  end

  # Call at most once per action per frame; repeating actions count frames held.
  def pressed?(action)
    held = @input.held?(action)
    repeat = Controls.repeat_for(action)
    return held unless repeat

    @pressed_for[action] = held ? @pressed_for.fetch(action, -1) + 1 : -1
    @pressed_for[action] % repeat == 0
  end
end
