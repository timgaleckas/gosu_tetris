class GameState
  attr_accessor :level

  def initialize
    @level = 1
    @rows_cleared = 0
  end

  def register_cleared_rows(number_of_rows)
    @rows_cleared += number_of_rows
    @level = @rows_cleared / 10 + 1
  end
end
