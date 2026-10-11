# Keyboard and gamepad buttons for each action the rules ask Controls about.
class GosuInput
  BUTTONS = {
    down:         [Gosu::KB_DOWN, Gosu::GP_0_DOWN],
    left:         [Gosu::KB_LEFT, Gosu::GP_0_LEFT],
    right:        [Gosu::KB_RIGHT, Gosu::GP_0_RIGHT],
    rotate_right: [Gosu::KB_UP, Gosu::GP_0_BUTTON_1],
    rotate_left:  [Gosu::GP_0_BUTTON_0]
  }.freeze

  PAUSE = [Gosu::KB_P, Gosu::GP_0_BUTTON_6].freeze

  def held?(action)
    BUTTONS.fetch(action).any? { |button| Gosu.button_down?(button) }
  end
end
