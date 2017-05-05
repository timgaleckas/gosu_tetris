require_relative './test_helper'

describe SpriteGeneration::MenuButton do
  describe "do it" do
    button = SpriteGeneration::MenuButton.draw_button("Options", false, true)
    button_hovered = SpriteGeneration::MenuButton.draw_button("Options", true, true)
    buttons = [
      [button, 0,0,1],
      [button_hovered, 0,0,1],
      [button, 0,0,1],
      [button_hovered, 0,0,1],
      [button, 0,0,1],
      [button_hovered, 0,0,1]
    ]
    TestWindow.new(buttons,20).show

    button.save(App.asset_root / 'buttons' / 'options.png')
    button_hovered.save(App.asset_root / 'buttons' / 'options_hovered.png')

    button = SpriteGeneration::MenuButton.draw_button("Start Game", false)
    button_hovered = SpriteGeneration::MenuButton.draw_button("Start Game", true)
    buttons = [
      [button, 0,0,1],
      [button_hovered, 0,0,1],
      [button, 0,0,1],
      [button_hovered, 0,0,1],
      [button, 0,0,1],
      [button_hovered, 0,0,1]
    ]
    TestWindow.new(buttons,20).show

    button.save(App.asset_root / 'buttons' / 'start_game.png')
    button_hovered.save(App.asset_root / 'buttons' / 'start_game_hovered.png')
  end
end
