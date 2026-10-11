require_relative '../test_helper'

describe Menu::MainScreen do
  def menu
    m = Menu::MainScreen.new(Screen.new(400, 600, nil))
    m._buttons.first.hovered = true
    m
  end

  def hovered_index(m)
    m._buttons.index(&:hovered?)
  end

  [Gosu::KB_DOWN, Gosu::GP_DOWN, Gosu::GP_0_DPAD_DOWN, Gosu::GP_1_DOWN].each do |id|
    it "moves down with button #{id}" do
      m = menu
      m.button_down(id)
      _(hovered_index(m)).must_equal 1
    end
  end

  [Gosu::KB_UP, Gosu::GP_UP, Gosu::GP_0_DPAD_UP].each do |id|
    it "moves up with button #{id}" do
      m = menu
      m.button_down(Gosu::KB_DOWN)
      m.button_down(id)
      _(hovered_index(m)).must_equal 0
    end
  end

  [Gosu::KB_RETURN, Gosu::GP_BUTTON_0, Gosu::GP_0_BUTTON_1].each do |id|
    it "selects with button #{id}" do
      m = menu
      m.button_down(id)
      _(m.next_screen).must_be_kind_of Menu::GameModeScreen
    end
  end

  it "doesn't select with a gamepad direction" do
    m = menu
    m.button_down(Gosu::GP_0_DPAD_LEFT)
    assert_nil m.next_screen
  end
end
