# Draws into a render target using top-left coordinates, the way the Gosu version lays
# things out, converting to DragonRuby's bottom-left origin.
class Canvas
  WHITE = [255, 255, 255].freeze

  def initialize(target, width, height)
    @target = target
    @height = height
    @target.w = width
    @target.h = height
    @target.background_color = [0, 0, 0, 0]
  end

  # extra: more sprite properties, such as tile_x/tile_y/tile_w/tile_h.
  def sprite(x, y, w, h, path, extra = nil)
    primitive = { x: x, y: @height - y - h, w: w, h: h, path: path }
    primitive.merge!(extra) if extra
    @target.primitives << primitive
  end

  def rect(x, y, w, h, color)
    @target.primitives << { x: x, y: @height - y - h, w: w, h: h, path: :solid,
                            r: color[0], g: color[1], b: color[2], a: color[3] || 255 }
  end

  def text(x, y, string, size_px, font, color = WHITE)
    @target.primitives << { x: x, y: @height - y, text: string, size_px: size_px, font: font,
                            anchor_x: 0, anchor_y: 1, r: color[0], g: color[1], b: color[2] }
  end
end
