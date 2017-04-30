class MainBoard < Widget
  include Suspendable
  def suspended?
    @game_state.paused? || @game_state.ended?
  end

  attr_reader :current_piece

  def initialize(widget_width, widget_height, game_state)
    super(widget_width, widget_height)

    @game_state = game_state

    @squares_wide = @width / Square.width
    @board_width = @squares_wide * Square.width

    @x = (@width % Square.width) / 2

    @squares_high = (@height / Square.height) + 1

    @board_height = @squares_high * Square.height

    @y = @height - @board_height

    @rows = 0.upto(@squares_high - 1).map{|_|[nil]*@squares_wide}

    @current_piece_resting_for = 0

    @moves_with_current_piece = 0

    @animations_pending = []
  end

  suspendable def current_piece=(piece)
    @current_piece = piece
    @cursor_x = ((@squares_wide / 2) - 1) * Square.width
    @cursor_y = -(Square.height*2)
    @moves_with_current_piece = 0
  end

  def draw
    Gosu.clip_to(0, 0, width, height) do
      Gosu.translate(@x, @y) do
        @rows.each_with_index do |row, row_index|
          row.each_with_index do |square, square_index|
            if square
              square.draw(square_index * Square.width, row_index * Square.height, 1)
            end
          end
        end
        _current_piece_squares_with_coordinates.each do |(square, x, y)|
          square.draw(x,y,2)
        end
      end
    end
    _pop_animation_pending(:flush) if _animation_pending == :flush
  end

  suspendable def move_piece_left
    unless _collision_detected?(@current_piece, @cursor_x - Square.width, _cursor_y, Tunables.slide_buffer)
      if _collision_detected?(@current_piece, @cursor_x - Square.width, _cursor_y)
        @cursor_y = (_cursor_y + 15) / 30 * 30
      end
      @cursor_x -= Square.width
      @moves_with_current_piece += 1
    end
  end

  suspendable def move_piece_right
    unless _collision_detected?(@current_piece, @cursor_x + Square.width, _cursor_y, Tunables.slide_buffer)
      if _collision_detected?(@current_piece, @cursor_x - Square.width, _cursor_y)
        @cursor_y = (_cursor_y + 15) / 30 * 30
      end
      @cursor_x += Square.width
      @moves_with_current_piece += 1
    end
  end

  def needs_next_piece?
    @current_piece.nil? && @animations_pending.empty?
  end

  suspendable def update
    case _animation_pending
    when :clear_rows
      _clear_rows
    when :apply_gravity
      _apply_gravity
    when :flush
      #wait for display
    else
      _update_current_piece if @current_piece
    end
  end

  def _animation_pending
    @animations_pending.first
  end

  def _animation_pending=(animation_pending)
    @animations_pending << animation_pending
  end

  def _apply_gravity
    changed_this_frame = []
    (@rows.size-2).downto(0).each do |row_index|
      @rows[row_index].each_with_index do |square, column_index|
        if square && !square.locked? && !_square_at_index(column_index, row_index+1)
          @rows[row_index+1][column_index]=square
          @rows[row_index][column_index]=nil
          changed_this_frame << [column_index, row_index+1]
          @gravity_happened = true
        end
      end
    end
    if !changed_this_frame.empty?
      changed_this_frame.each do |x,y|
        _square_at_index(x,y).lock if _index_out_of_bounds?(x,y+1) || _square_at_index(x,y+1).try(:locked?)
      end
    elsif @gravity_happened
      _relink_and_relock_squares
      _pop_animation_pending(:apply_gravity)
      self._animation_pending=:clear_rows
      @gravity_happened = false
    else
      _pop_animation_pending(:apply_gravity)
    end
  end

  def _clear_rows
    rows_cleared = 0
    @rows.reject! do |r|
      if r.all?{|s|s}
        rows_cleared += 1
        r.each{|s| s.left = s.right = s.up = s.down = nil }
        true
      else
        false
      end
    end
    @game_state.register_cleared_rows(rows_cleared)
    @rows.size.upto(@squares_high - 1){ @rows.unshift [nil]*@squares_wide}
    @rows.each_with_index do |row, row_index|
      row.each_with_index do |square, column_index|
        if square
          if column_index > 0
            square.left = @rows[row_index][column_index - 1]
          else
            square.left = nil
          end
          if row_index > 0
            square.up = @rows[row_index - 1][column_index]
          else
            square.up = nil
          end
          if row_index == @rows.size - 1
            square.down = nil
          end
          square.unlock
        else
          @rows[row_index][column_index - 1].try(:right=, nil) if column_index > 0
          @rows[row_index - 1][column_index].try(:down=, nil) if row_index > 0
        end
      end
    end
    @rows.last.each do |square|
      square.try(:lock)
    end

    _pop_animation_pending(:clear_rows)
    self._animation_pending=:apply_gravity

    _apply_gravity if rows_cleared == 0
  end

  def _collision_detected?(piece, cursor_x, cursor_y, buffer=0)
    return false unless piece
    piece.squares_with_coordinates(cursor_x, cursor_y).find do |(_, x, y)|
      _out_of_bounds?(x,y) || _out_of_bounds?(x+Square.width,y+Square.height) ||
      _square_at?(x,y+buffer) || _square_at?(x-1+Square.width,y+Square.height-1-buffer)
    end
  end

  def _current_piece_squares_with_coordinates
    @current_piece ? @current_piece.squares_with_coordinates(@cursor_x, _cursor_y) : []
  end

  def _cursor_y
    @cursor_y.to_i
  end

  def _end_game
  end

  def _index_out_of_bounds?(x,y)
    x < 0 || y < 0 || x >= @squares_wide || y >= @squares_high
  end

  def _out_of_bounds?(x,y)
    x < 0 || x > (_squares_wide * Square.width) ||
      y > (_squares_high * Square.height)
  end

  def _place_piece
    _current_piece_squares_with_coordinates.each do |(square, x, y)|
      row = y/Square.height
      column = x/Square.width
      @rows[row][column]=square
    end
    @current_piece = nil
    self._animation_pending=:clear_rows
  end

  def _pop_animation_pending(animation_on_top)
    raise "invalid state #{_animation_pending} instead of #{animation_on_top}" unless @animations_pending.first == animation_on_top
    @animations_pending.shift
  end

  def _relink_and_relock_squares
    @rows.each_with_index do |row, row_index|
      row.each_with_index do |square, column_index|
        square.try(:unlock)
        square.try(:up=,    _index_out_of_bounds?(column_index, row_index - 1) ? nil : _square_at_index(column_index, row_index - 1), false)
        square.try(:down=,  _index_out_of_bounds?(column_index, row_index + 1) ? nil : _square_at_index(column_index, row_index + 1), false)
        square.try(:left=,  _index_out_of_bounds?(column_index - 1, row_index) ? nil : _square_at_index(column_index - 1, row_index), false)
        square.try(:right=, _index_out_of_bounds?(column_index + 1, row_index) ? nil : _square_at_index(column_index + 1, row_index), false)
      end
    end
    @rows.last.each{|s|s.try(:lock)}
  end

  def _rotate_piece_left
    unless _collision_detected?(@current_piece.rotated_left, @cursor_x, _cursor_y, Tunables.slide_buffer)
      @current_piece = @current_piece.rotated_left
      @moves_with_current_piece += 1
    end
  end

  def _rotate_piece_right
    unless _collision_detected?(@current_piece.rotated_right, @cursor_x, _cursor_y, Tunables.slide_buffer)
      @current_piece = @current_piece.rotated_right
      @moves_with_current_piece += 1
    end
  end

  def _rows
    @rows
  end

  def _square_at?(x,y)
    return nil if _out_of_bounds?(x,y)
    return nil if y < 0
    @rows[y/Square.height][x/Square.width]
  end

  def _square_at_index(x,y)
    raise "out of bounds" if _index_out_of_bounds?(x,y)
    @rows[y][x]
  end

  def _squares_high
    @squares_high
  end

  def _squares_wide
    @squares_wide
  end

  def _update_current_piece
    if Gosu.button_down? @game_state.key_map.right
      move_piece_right if (@pressing_right_time % Tunables.slide_repeat) == 0
      @pressing_right_time += 1
    else
      @pressing_right_time = 0
    end

    if Gosu.button_down? @game_state.key_map.left
      move_piece_left if (@pressing_left_time % Tunables.slide_repeat) == 0
      @pressing_left_time += 1
    else
      @pressing_left_time = 0
    end

    if Gosu.button_down? @game_state.key_map.rotate_right
      _rotate_piece_right if (@pressing_rotate_right_time % Tunables.rotate_repeat) == 0
      @pressing_rotate_right_time += 1
    else
      @pressing_rotate_right_time = 0
    end

    if Gosu.button_down? @game_state.key_map.rotate_left
      _rotate_piece_left if (@pressing_rotate_left_time % Tunables.rotate_repeat) == 0
      @pressing_rotate_left_time += 1
    else
      @pressing_rotate_left_time = 0
    end

    move_down_amount = Tunables.speed_for_level(@game_state.level)
    move_down_amount += Tunables.down_speed if Gosu.button_down? @game_state.key_map.down

    if _collision_detected?(@current_piece, @cursor_x, _cursor_y + move_down_amount)
      until _collision_detected?(@current_piece, @cursor_x, _cursor_y + 1)
        @cursor_y += 1
      end

      @current_piece_resting_for += 1
      if @current_piece_resting_for >= Tunables.lock_delay
        if @moves_with_current_piece == 0
          _end_game
        else
          _place_piece
        end
      end
    else
      @cursor_y += move_down_amount
      @current_piece_resting_for = 0
      @moves_with_current_piece += 1
    end
  end

  def _x
    @x
  end

  def _y
    @y
  end
end
