class SpriteGeneration::MenuButton
  class << self
    include Magick
    def draw_button(text, hovered=false, has_descent=false, x_padding=20, y_padding=20)
      caption = Magick::Draw.new
      caption.stroke(Colors::MENU_BUTTON_TEXT_HEX)
      caption.fill(Colors::MENU_BUTTON_TEXT_HEX)
      caption.font(App.asset_root / "fonts" / "Courgette" / "Courgette-Regular.ttf")
      caption.font_weight = 400
      caption.pointsize = 50
      caption.align = CenterAlign
      type_metrics = caption.get_type_metrics(text)

      image_width  = type_metrics.width+(x_padding*2)
      image_height = type_metrics.height+(y_padding*2)
      image = Image.new(image_width, image_height) { self.background_color = "transparent" }

      button = Magick::Draw.new
      button.stroke(Colors::MENU_BUTTON_BG_HEX)
      button.fill(hovered ? Colors::MENU_BUTTON_FG_HOVERED_HEX : Colors::MENU_BUTTON_FG_HEX)
      button.stroke_width = 3
      button.roundrectangle(3, 3, image_width - 3, image_height - 3, 5, 5)

      button.draw(image)

      caption.gravity = SouthGravity
      caption.text(image_width/2,image_height/2 + (has_descent ? 15 : 20),text)
      caption.draw(image)

      Gosu::Image.new(image)
    end
  end
end
