# DragonRuby's side of the rules' ports: input (held?(action)) and audio (play(name)).
# Both read or write args, so the screen hands them the current tick's args.
class DrInput
  attr_writer :inputs

  def held?(action)
    keyboard = @inputs.keyboard
    controller = @inputs.controller_one
    case action
    when :down         then keyboard.down_arrow || controller.down
    when :left         then keyboard.left_arrow || controller.left
    when :right        then keyboard.right_arrow || controller.right
    when :rotate_right then keyboard.up_arrow || controller.east
    when :rotate_left  then controller.south
    else false
    end
  end

  def pause_pressed?
    @inputs.keyboard.key_down.p || @inputs.controller_one.key_down.start
  end
end

class DrAudio
  attr_writer :outputs

  def play(name)
    @outputs.sounds << "assets/sounds/#{name.downcase}.ogg"
  end
end
