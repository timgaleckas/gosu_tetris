require_relative '../test_helper'

describe SpriteGeneration::MenuButton do
  describe "do it" do
    image = SpriteGeneration::MenuButton.draw_button("Options", true)
    TestWindow.new([[image,0,0,1]],20).show
    image.save(App.asset_root / 'buttons' / 'options.png')

    image = SpriteGeneration::MenuButton.draw_button("Start Game")
    TestWindow.new([[image,0,0,1]],20).show
    image.save(App.asset_root / 'buttons' / 'start_game.png')
  end
end
