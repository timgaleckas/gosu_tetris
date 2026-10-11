# DragonRuby's side of the rules' ports: input (held?(action)) and audio (play(name)).
# Both read or write args, so the screen hands them the current tick's args.
class DrInput
  ACTIONS = [:down, :left, :right, :rotate_right, :rotate_left].freeze

  # What the controls screen shows; keep in step with _down? and pause_pressed?.
  # Each is [action, keyboard, gamepad].
  LABELS = [
    ['Move', 'Left, Right', 'D-pad'],
    ['Drop faster', 'Down', 'D-pad down'],
    ['Rotate right', 'Up or X', 'B (right)'],
    ['Rotate left', 'Z', 'A (bottom)'],
    ['Pause', 'Esc or P', 'Start']
  ].freeze

  # Actions start suppressed, so a button still held from the menu doesn't move the
  # first piece.
  def initialize
    suppress_held
  end

  def inputs=(inputs)
    @inputs = inputs
    @suppressed.reject! { |action| !_down?(action) }
  end

  # Ignores whatever is held now until it's released.
  def suppress_held
    @suppressed = ACTIONS.dup
  end

  def held?(action)
    _down?(action) && !@suppressed.include?(action)
  end

  def pause_pressed?
    key_down = @inputs.keyboard.key_down
    key_down.p || key_down.escape || @inputs.controller_one.key_down.start
  end

  def _down?(action)
    keyboard = @inputs.keyboard
    controller = @inputs.controller_one
    case action
    when :down         then keyboard.down_arrow || controller.down
    when :left         then keyboard.left_arrow || controller.left
    when :right        then keyboard.right_arrow || controller.right
    when :rotate_right then keyboard.up_arrow || keyboard.x || controller.east
    when :rotate_left  then keyboard.z || controller.south
    else false
    end
  end
end

class DrAudio
  attr_writer :outputs

  # Plays assets/sounds/<name, lowercased>.ogg at the volume in Settings.
  def self.play(outputs, name)
    volume = Settings[:volume]
    outputs.sounds << { path: "assets/sounds/#{name.downcase}.ogg", gain: volume / 10.0 } if volume > 0
  end

  def play(name)
    DrAudio.play(@outputs, name)
  end
end
