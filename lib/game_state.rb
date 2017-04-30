class GameState
  attr_accessor :level
  attr_accessor :paused
  attr_accessor :ended

  def initialize
    @level = 1
    @rows_cleared = 0
    @paused = false
  end

  def register_cleared_rows(number_of_rows)
    @rows_cleared += number_of_rows
    level_from_rows = @rows_cleared / 10 + 1
    @level = [@level, level_from_rows].max
  end

  def paused?
    !!@paused
  end

  def ended?
    !!@ended
  end
end
