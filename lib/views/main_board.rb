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

    @rows = []
    _refill_rows

    ((@rows.size - @game_state.junk_level)...@rows.size).each do |row_index|
      (0...@squares_wide).each do |column_index|
        @rows[row_index][column_index] = Square.new(7,@game_state,true) if rand(5) == 0
      end
    end

    @actions_pending = []

    @pressing_rotate_left_time =
      @pressing_rotate_right_time =
      @current_piece_resting_for =
      0
  end

  suspendable def current_piece=(piece)
    @current_piece = piece
    @cursor_x = ((@squares_wide / 2) - 1) * Square.width
    @cursor_y = -(Square.height*2)
    _lose_game if _collision_detected?(@current_piece, @cursor_x, _cursor_y)
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
  end

  suspendable def move_piece_left
    unless _collision_detected?(@current_piece, @cursor_x - Square.width, _cursor_y, Tunables.slide_buffer)
      @cursor_x -= Square.width
      _shimmy_piece_to_fit
    end
  end

  suspendable def move_piece_right
    unless _collision_detected?(@current_piece, @cursor_x + Square.width, _cursor_y, Tunables.slide_buffer)
      @cursor_x += Square.width
      _shimmy_piece_to_fit
    end
  end

  def needs_next_piece?
    @current_piece.nil? && !_peek_action_pending
  end

  suspendable def update
    case _pop_action_pending
    when :clear_rows
      _clear_rows
    when :clear_squares
      _clear_squares
    when :apply_gravity
      _apply_gravity
    when :drop_squares
      _drop_squares
    when :flush_display
      nil
    when nil
      _update_current_piece if @current_piece
      @game_state.won = true if @game_state.junk_level > 0 && @rows.flatten.compact.none?{|s|s.permalocked?}
    else
    end
  end

  def _peek_action_pending
    @actions_pending.last
  end

  def _pop_action_pending
    @actions_pending.pop
  end

  def _push_action_pending(action)
    @actions_pending.push(action)
  end

  def _apply_gravity(initial=true)
    return unless @game_state.gravity
    _relink_and_relock_squares if initial
    changed_this_frame = []
    (@rows.size-2).downto(0).each do |row_index|
      @rows[row_index].each_with_index do |square, column_index|
        if square && !square.locked? && !_square_at_index(column_index, row_index+1)
          @rows[row_index+1][column_index]=square
          @rows[row_index][column_index]=nil
          square.dropping += Square.height
          changed_this_frame << [column_index, row_index+1]
        end
      end
    end
    changed_this_frame.each do |x,y|
      _square_at_index(x,y).lock if _index_out_of_bounds?(x,y+1) || _square_at_index(x,y+1).try(:locked?)
    end
    if !changed_this_frame.empty?
      _apply_gravity(false)
      if initial
        _relink_and_relock_squares
        _push_action_pending(:clear_rows)
        _push_action_pending(:drop_squares)
      end
    end
  end

  def _clear_rows
    rows_to_clear = @rows.select{|r|r.all?{|s|s}}
    unless rows_to_clear.empty?
      @game_state.register_cleared_rows(@current_cascade,rows_to_clear.size)
      @current_cascade += 1

      rows_to_clear.each do |r|
        r.each do |s|
          s.left = s.right = s.up = s.down = nil
          s.disappearing += 1
        end
      end

      _push_action_pending(:apply_gravity)
      _push_action_pending(:clear_squares)
    end
  end

  def _clear_squares
    @rows.each_with_index do |row, row_index|
      row.each_with_index do |square, column_index|
        if square && square.disappearing?
          square.disappearing+=1
          if square.disappeared?
            @rows[row_index][column_index] = nil unless @game_state.drop_cleared_rows
          else
            _push_action_pending(:clear_squares) unless _peek_action_pending == :clear_squares
          end
        end
      end
    end

    if @game_state.drop_cleared_rows
      @rows.reject!{|row|row.all?{|s|s && s.disappeared?}}
      _refill_rows if @rows.size < @squares_high
    end
  end

  def _drop_squares
    @rows.each_with_index do |row, row_index|
      row.each_with_index do |square, column_index|
        if square && square.dropping?
          square.dropping-=Tunables.drop_rate
          if square.dropping?
            _push_action_pending(:drop_squares) unless _peek_action_pending == :drop_squares
          end
        end
      end
    end
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

  def _lose_game
    @game_state.lost = true
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
    _relink_and_relock_squares
    @current_cascade = 0
    _push_action_pending(:apply_gravity)
    _push_action_pending(:clear_rows)
  end

  def _refill_rows
    (@rows.size...@squares_high).each do |i|
      @rows.unshift [nil]*@squares_wide
    end
    _relink_and_relock_squares
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
    @rows.flatten.select{|s|s.try(:permalocked?)}.each{|s|s.lock}
  end

  def _rotate_piece_left
    rotated_left_piece = @current_piece.rotated_left
    x_offset, y_offset = ([[0,0]] + @current_piece.rotated_right_kick_offsets).find do |(_x_offset,_y_offset)|
      !_collision_detected?(rotated_left_piece, @cursor_x + (_x_offset * Square.width), _cursor_y + (_y_offset * Square.height), Tunables.slide_buffer)
    end
    if x_offset
      @current_piece = rotated_left_piece
      @cursor_x += (x_offset * Square.width)
      @cursor_y += (y_offset * Square.height)
      _shimmy_piece_to_fit
    end
  end

  def _rotate_piece_right
    rotated_right_piece = @current_piece.rotated_right
    x_offset, y_offset = ([[0,0]] + @current_piece.rotated_right_kick_offsets).find do |(_x_offset,_y_offset)|
      !_collision_detected?(rotated_right_piece, @cursor_x + (_x_offset * Square.width), _cursor_y + (_y_offset * Square.height), Tunables.slide_buffer)
    end
    if x_offset
      @current_piece = rotated_right_piece
      @cursor_x += (x_offset * Square.width)
      @cursor_y += (y_offset * Square.height)
      _shimmy_piece_to_fit
    end
  end

  def _rows
    @rows
  end

  def _shimmy_piece_to_fit
    @cursor_y = (_cursor_y + 15) / 30 * 30 if _collision_detected?(@current_piece, @cursor_x, _cursor_y)
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

  def _repeatable_key(is_pressed, repeat, &block)

  end

  def _update_current_piece
    move_piece_right    if @game_state.key_map.right_pressed?
    move_piece_left     if @game_state.key_map.left_pressed?
    _rotate_piece_right if @game_state.key_map.rotate_right_pressed?
    _rotate_piece_left  if @game_state.key_map.rotate_left_pressed?

    move_down_amount = Tunables.speed_for_level(@game_state.speed_level)
    move_down_amount += Tunables.down_speed if @game_state.key_map.down_pressed?

    if _collision_detected?(@current_piece, @cursor_x, _cursor_y + move_down_amount)
      until _collision_detected?(@current_piece, @cursor_x, _cursor_y + 1)
        @cursor_y += 1
      end

      @current_piece_resting_for += 1
      if @current_piece_resting_for >= Tunables.lock_delay
        _place_piece
      end
    else
      @cursor_y += move_down_amount
      @current_piece_resting_for = 0
    end
  end

  def _x
    @x
  end

  def _y
    @y
  end
end
