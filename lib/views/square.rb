class Square < Widget
  attr_reader :color_index
  attr_accessor :parent
  attr_reader :left, :right, :up, :down

  def initialize(color_index, game_state)
    super Square.width, Square.height
    @color_index = color_index % Sprites::SQUARES.first.size
    @game_state = game_state
    @parent = parent
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
    !!@locked
  end

  def draw(x, y, z)
    Sprites::SQUARES[(@game_state ? @game_state.level : 0) % Sprites::SQUARES.size][@color_index].draw(x, y, z)
    Sprites::STITCHES.draw(x,y,z+1) if color_index == right.try(:color_index)
    Sprites::STITCHES.draw_rot(x,y,z+1,90.0,0,1) if color_index == down.try(:color_index)
  end

  def self.height
    Sprites::SQUARE_HEIGHT
  end

  def self.width
    Sprites::SQUARE_WIDTH
  end
end
