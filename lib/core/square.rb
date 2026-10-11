class Square
  DISAPPEAR_LIMIT = 10
  SIZE = 30

  attr_reader :color_index
  attr_reader :game_state
  attr_reader :left, :right, :up, :down
  attr_accessor :disappearing
  attr_accessor :dropping

  def initialize(color_index, game_state, permalocked=false)
    @color_index = color_index
    @game_state = game_state
    @disappearing = 0
    @dropping = 0
    @permalocked = permalocked
  end

  # The setters link both ways: the new neighbor points back and the old one lets go.
  def right=(square)
    @right._set_left(nil) if @right
    square._set_left(self) if square
    @right = square
  end

  def left=(square)
    @left._set_right(nil) if @left
    square._set_right(self) if square
    @left = square
  end

  def up=(square)
    @up._set_down(nil) if @up
    square._set_down(self) if square
    @up = square
  end

  def down=(square)
    @down._set_up(nil) if @down
    square._set_up(self) if square
    @down = square
  end

  # Sets all four neighbors one way, leaving the neighbors untouched.
  def relink(up, down, left, right)
    @up, @down, @left, @right = up, down, left, right
  end

  def _set_left(square)
    @left = square
  end

  def _set_right(square)
    @right = square
  end

  def _set_up(square)
    @up = square
  end

  def _set_down(square)
    @down = square
  end

  def lock
    unless @locked
      @locked = true
      @up.lock if @up
      @down.lock if @down && @down.color_index == color_index
      @left.lock if @left && @left.color_index == color_index
      @right.lock if @right && @right.color_index == color_index
    end
  end

  def unlock
    @locked = false
  end

  def locked?
    permalocked? || !!@locked
  end

  def permalocked?
    !!@permalocked
  end

  def disappearing?
    @disappearing > 0 && !disappeared?
  end

  def disappeared?
    @disappearing >= DISAPPEAR_LIMIT
  end

  def dropping?
    @dropping > 0
  end

  def inspect
    [
      locked? ? 'L' : '.',
      up ?      'U' : '.',
      down ?    'D' : '.',
      left ?    'L' : '.',
      right ?   'R' : '.'
    ].join
  end

  def self.height
    SIZE
  end

  def self.width
    SIZE
  end
end
