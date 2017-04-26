class MainBoard
  attr_reader :current_piece
  attr_accessor :pressing_down

  def initialize(widget_x,widget_y,widget_width,widget_height)
    @widget_x, @widget_y, @widget_width, @widget_height =
      widget_x, widget_y, widget_width, widget_height

    @squares_wide = @widget_width / Square.width
    @width = @squares_wide * Square.width

    x_padding = (@widget_width % Square.width) / 2
    @x = @widget_x + x_padding

    @squares_high = (@widget_height / Square.height) + 1

    @height = @squares_high * Square.height

    @y = @widget_height - @height

    @rows = 0.upto(@squares_high).map{|_|[nil]*@squares_wide}
    @speed = 1
  end

  def current_piece=(piece)
    @current_piece = piece
    @cursor_x = (@squares_wide / 2) * Square.width
    @cursor_y = -(Square.height*2)
  end

  def draw
    Gosu.clip_to(@widget_x, @widget_y, @widget_width, @widget_height) do
      Gosu.translate(@x,@y) do
        @rows.each_with_index do |row, row_index|
          row.each_with_index do |square, square_index|
            square && square.draw(square_index * Square.width, row_index * Square.height, 1)
          end
        end
        _current_piece_squares_with_coordinates.each do |(square, x, y)|
          square.draw(x,y,2)
        end
      end
    end
  end

  def move_piece_left
    @cursor_x -= Square.width unless _collision_detected?(@current_piece, @cursor_x - Square.width, @cursor_y)
  end

  def move_piece_right
    @cursor_x += Square.width unless _collision_detected?(@current_piece, @cursor_x + Square.width, @cursor_y)
  end

  def rotate_piece
    @current_piece = @current_piece.rotated_right unless _collision_detected?(@current_piece.rotated_right, @cursor_x, @cursor_y)
  end

  def update
    @cursor_y += @speed
    @cursor_y += 5 if pressing_down && !_collision_detected?(@current_piece, @cursor_x, @cursor_y + 5)
    _place_piece if _collision_detected?(@current_piece, @cursor_x, @cursor_y)
    @rows.reject!{|r|r&&r.all?{|s|s}}
    @rows.size.upto(@squares_high){ @rows.unshift [nil]*@squares_wide}
  end

  def _collision_detected?(piece, cursor_x, cursor_y)
    return false unless piece
    piece.squares_with_coordinates(cursor_x, cursor_y).find do |(_, x, y)|
      _out_of_bounds?(x,y) || _out_of_bounds?(x+Square.width,y+Square.height) ||
      _square_at?(x+1,y+1) || _square_at?(x-1+Square.width,y-1+Square.height)
    end
  end

  def _current_piece_squares_with_coordinates
    @current_piece ? @current_piece.squares_with_coordinates(@cursor_x, @cursor_y) : []
  end

  def _out_of_bounds?(x,y)
    x < 0 || x > (_squares_wide * Square.width) ||
      y > (_squares_high * Square.height)
  end

  def _place_piece
    _current_piece_squares_with_coordinates.each do |(square, x, y)|
      @rows[y/Square.height][x/Square.width]=square
    end
    @current_piece = nil
  end

  def _square_at?(x,y)
    return nil if _out_of_bounds?(x,y)
    @rows[y/Square.height][x/Square.width]
  end

  def _squares_high
    @squares_high
  end

  def _squares_wide
    @squares_wide
  end

  def _x
    @x
  end

  def _y
    @y
  end
end
