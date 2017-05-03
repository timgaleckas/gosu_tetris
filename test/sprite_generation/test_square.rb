require_relative '../test_helper'

describe SpriteGeneration::Square do
  describe "do it" do
    image = SpriteGeneration::Square.generate_sprite_sheet
    TestWindow.new([[image,0,0,1]],20).show
    image = SpriteGeneration::Square.generate_border_sprite_sheet
    TestWindow.new([[image,0,0,1]],20).show
    SpriteGeneration::Square.write_files
  end
end
