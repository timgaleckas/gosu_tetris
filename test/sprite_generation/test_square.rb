require_relative '../test_helper'

describe SpriteGeneration::Square do
  describe "do it" do
    image = SpriteGeneration::Square.generate_sprite_sheet
    TestWindow.new([[image,0,0,1]],200).show
    SpriteGeneration::Square.write_file
  end
end
