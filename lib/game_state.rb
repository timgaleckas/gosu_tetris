class GameState
  attr_accessor :level
  attr_accessor :paused
  attr_accessor :ended
  attr_accessor :player_id
  attr_reader :rows_cleared
  attr_reader :score

  def initialize
    @level = 0
    @rows_cleared = 0
    @paused = false
    @player_id = 0
    @score = 0
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

  def register_cleared_rows(current_cascade, number_of_rows)
    @rows_cleared += number_of_rows
    row_score = case number_of_rows
                when 1
                  40
                when 2
                  100
                when 3
                  300
                when 4
                  1200
                else
                  0
                end
    @score += (@level + 1) * row_score
    @score += current_cascade*50
    level_from_rows = @rows_cleared / 10
    @level = [@level, level_from_rows].max
  end
end
