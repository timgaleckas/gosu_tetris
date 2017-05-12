class Square < Widget
  DISAPPEAR_LIMIT = 10

  attr_reader :color_index
  attr_reader :left, :right, :up, :down
  attr_accessor :disappearing
  attr_accessor :dropping

  def initialize(color_index, game_state, permalocked=false)
    super Square.width, Square.height
    @color_index = color_index
    @game_state = game_state
    @disappearing = 0
    @dropping = 0
    @permalocked = permalocked
  end

  def right=(square, doubly_link=true)
    @right.try(:left=,nil,false) if doubly_link
    square.try(:left=,self,false) if doubly_link
    @right=square
  end

  def left=(square, doubly_link=true)
    @left.try(:right=,nil,false) if doubly_link
    square.try(:right=,self,false) if doubly_link
    @left=square
  end

  def up=(square, doubly_link=true)
    @up.try(:down=,nil,false) if doubly_link
    square.try(:down=,self,false) if doubly_link
    @up=square
  end

  def down=(square, doubly_link=true)
    @down.try(:up=,nil,false) if doubly_link
    square.try(:up=,self,false) if doubly_link
    @down=square
  end

  def lock
    unless @locked
      @locked = true
      @up.try(:lock)
      @down.try(:lock) if @down.try(:color_index) == color_index
      @left.try(:lock) if @left.try(:color_index) == color_index
      @right.try(:lock) if @right.try(:color_index) == color_index
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

  def draw(x, y, z)
    Gosu.scale(1 - (@disappearing.to_f / DISAPPEAR_LIMIT), 1 - (@disappearing.to_f / DISAPPEAR_LIMIT), x+(Sprites::SQUARE_WIDTH/2), y+(Sprites::SQUARE_HEIGHT/2)) do
      level_index = (@game_state ? @game_state.level : 0) % 10
      index = level_index * 8 + @color_index
      Sprites::SQUARES[index].draw(x, y-@dropping, z)
      border_index = [
        !permalocked? && color_index == left.try(:color_index) ? "0" : "1",
        !permalocked? && color_index == right.try(:color_index) ? "0" : "1",
        !permalocked? && color_index == up.try(:color_index) ? "0" : "1",
        !permalocked? && color_index == down.try(:color_index) ? "0" : "1"
      ].join.to_i(2)

      Sprites::BORDERS[border_index].draw(x,y-@dropping, z+1)
    end
  end

  def self.height
    Sprites::SQUARE_HEIGHT
  end

  def self.width
    Sprites::SQUARE_WIDTH
  end

  def self.stitch_width
    Sprites::STITCH_WIDTH
  end
end
