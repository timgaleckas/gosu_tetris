class NextPiece
  def initialize(width, height)
    @width, @height = width, height
    pop
  end

  def draw
    x = @width/2 - @current.width/2
    y = @height/2 - @current.height/2
    @current.draw(x,y,1)
  end

  def pop
    last = @current
    @current = Piece::ALL.sample
    0.upto(3).to_a.sample.times do
      @current = @current.rotated_right
    end
    last
  end
end
