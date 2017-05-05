require_relative './test_helper'

describe SpriteGeneration::Square do
  describe "do it" do
    sprite_sheet = SpriteGeneration::Square.generate_sprite_sheet
    TestWindow.new([[sprite_sheet,0,0,1]],20).show
    sprite_sheet.save(App.asset_root / 'blocks.png')

    border_sprite_sheet = SpriteGeneration::Square.generate_border_sprite_sheet
    TestWindow.new([[border_sprite_sheet,0,0,1]],20).show
    border_sprite_sheet.save(App.asset_root / 'borders.png')
  end
end
