# Draws into a render target using top-left coordinates, converting to DragonRuby's
# bottom-left origin.
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

  # align: where x falls on the text (0 left, 0.5 center, 1 right); valign likewise for y,
  # from the top.
  def text(x, y, string, size_px, font, color = WHITE, align: 0, valign: 0)
    @target.primitives << { x: x, y: @height - y, text: string, size_px: size_px, font: font,
                            anchor_x: align, anchor_y: 1 - valign, r: color[0], g: color[1], b: color[2] }
  end

  # Stretches an image to w x h, keeping its corner pixels (corner square) unscaled.
  def nine_slice(x, y, w, h, path, image_size, corner)
    middle = image_size - 2 * corner
    columns = [[x, 0, corner], [x + corner, corner, w - 2 * corner], [x + w - corner, image_size - corner, corner]]
    rows = [[y, 0, corner], [y + corner, corner, h - 2 * corner], [y + h - corner, image_size - corner, corner]]
    rows.each do |(top, tile_y, height)|
      columns.each do |(left, tile_x, width)|
        sprite(left, top, width, height, path,
               tile_x: tile_x, tile_y: tile_y,
               tile_w: tile_x == corner ? middle : corner, tile_h: tile_y == corner ? middle : corner)
      end
    end
  end
end
