require_relative './test_helper'

describe SpriteGeneration::MenuButton do
  def buttons(text, has_descent)
    button = SpriteGeneration::MenuButton.draw_button(text, false, has_descent)
    button_hovered = SpriteGeneration::MenuButton.draw_button(text, true, has_descent)
    buttons = [
      [button, 0,0,1],
      [button_hovered, 0,0,1],
      [button, 0,0,1],
      [button_hovered, 0,0,1],
      [button, 0,0,1],
      [button_hovered, 0,0,1]
    ]
    TestWindow.new(buttons,20).show

    file_name = text.downcase.gsub(/ /,'_')
    button.save(App.asset_root / 'buttons' / "#{file_name}.png")
    button_hovered.save(App.asset_root / 'buttons' / "#{file_name}_hovered.png")
  end

  it "generates all menu buttons" do
    buttons("Options", true)
    buttons("Start Game", false)
    buttons("1 Player", true)
    buttons("2 Players", true)
    buttons("Classic", false)
    buttons("Next", false)
  end
end
