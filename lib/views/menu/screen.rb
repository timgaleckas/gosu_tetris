class Menu::Screen < Screen
  def initialize(width, height, window, buttons)
    super(width, height, window)
    buttons.each_with_index do |row, row_index|
      row.each_with_index do |button, column_index|
        button.down  = buttons[row_index+1].try(:slice, column_index)
        button.up    = buttons[row_index-1].try(:slice, column_index) if row_index > 0
        button.left  = buttons[row_index].try(:slice, column_index-1) if column_index > 0
        button.right = buttons[row_index].try(:slice, column_index+1)
      end
    end
    @buttons = buttons.flatten!
    @last_interaction = :mouse
    @last_mouse_x = nil
    @last_mouse_y = nil
  end

  def draw
    Gosu.draw_rect(0,0,@width,@height,Colors::MENU_BACKGROUND,1)
    @buttons.each{|b|b.draw}
  end

  def update
    @last_interaction = :mouse if @window.mouse_x != @last_mouse_x || @window.mouse_y != @last_mouse_y
    @last_mouse_x = @window.mouse_x
    @last_mouse_y = @window.mouse_y
    if @last_interaction == :mouse
      @buttons.each do |b|
        if b.within_bounds?(@window.mouse_x, @window.mouse_y)
          b.hovered = true
        else
          b.hovered = false
        end
      end
    elsif @buttons.none?{|b|b.hovered?}
      @buttons.first.hovered = true
    end

    @buttons.each{|b|b.update}
  end

  def button_down(id)
    case id
    when *([Gosu.constants.grep(/^Gp.*Down/)] + [Gosu::KbDown])
      _move_down
    when *([Gosu.constants.grep(/^Gp.*Up/)] + [Gosu::KbUp])
      _move_up
    when *([Gosu.constants.grep(/^Gp.*Right/)] + [Gosu::KbRight])
      _move_right
    when *([Gosu.constants.grep(/^Gp.*Left/)] + [Gosu::KbLeft])
      _move_left
    when *([Gosu.constants.grep(/^Gp/)] + [Gosu::KbReturn])
      _select_item
    when Gosu::MsLeft, Gosu::MsRight
      _select_item if @last_interaction == :mouse
    end

    case id
    when *Gosu.constants.map{|c|Gosu.const_get(c) if c =~ /^Kb/}.compact
      @last_interaction = :keyboard
    when *Gosu.constants.map{|c|Gosu.const_get(c) if c =~ /^Gp/}.compact
      @last_interaction = :gamepad
    when *Gosu.constants.map{|c|Gosu.const_get(c) if c =~ /^Ms/}.compact
      @last_interaction = :mouse
    end
  end

  def _move_down
    selected_button = @buttons.find{|b|b.hovered?}
    if selected_button && selected_button.down
      selected_button.down.hovered = true
      selected_button.hovered = false
    end
  end

  def _move_up
    selected_button = @buttons.find{|b|b.hovered?}
    if selected_button && selected_button.up
      selected_button.up.hovered = true
      selected_button.hovered = false
    end
  end

  def _move_right
    selected_button = @buttons.find{|b|b.hovered?}
    if selected_button && selected_button.right
      selected_button.right.hovered = true
      selected_button.hovered = false
    end
  end

  def _move_left
    selected_button = @buttons.find{|b|b.hovered?}
    if selected_button && selected_button.left
      selected_button.left.hovered = true
      selected_button.hovered = false
    end
  end

  def _select_item
    action = @buttons.find{|b|b.hovered?}.try(:action)
    instance_eval(&action) if action
  end

  def next_screen
    @next_screen
  end

  def needs_cursor?
    @last_interaction == :mouse
  end
end

