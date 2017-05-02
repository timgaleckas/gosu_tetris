class GameState
  attr_accessor :level
  attr_accessor :paused
  attr_accessor :ended
  attr_accessor :player_id

  def initialize
    @level = 0
    @rows_cleared = 0
    @paused = false
    @player_id = 0
  end

  def ended?
    !!@ended
  end

  def key_map
    KeyMap
  end

  def paused?
    !!@paused
  end

  def register_cleared_rows(number_of_rows)
    @rows_cleared += number_of_rows
    level_from_rows = @rows_cleared / 10
    @level = [@level, level_from_rows].max
  end
end
