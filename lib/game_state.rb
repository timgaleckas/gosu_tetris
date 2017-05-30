class GameState
  attr_accessor :drop_cleared_rows
  attr_accessor :gravity
  attr_accessor :junk_level
  attr_accessor :lost
  attr_accessor :marathon
  attr_accessor :multicolor
  attr_accessor :paused
  attr_accessor :player_id
  attr_accessor :speed_level
  attr_accessor :won
  attr_reader :rows_cleared
  attr_reader :score

  def initialize
    @drop_cleared_rows = false
    @gravity = true
    @junk_level = 2
    @marathon = false
    @multicolor = true
    @paused = false
    @player_id = 0
    @rows_cleared = 0
    @score = 0
    @speed_level = 0
  end

  def ended?
    won || lost
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
    @score += (@speed_level + 1) * row_score
    @score += current_cascade*50
    speed_level_from_rows = @rows_cleared / 10
    Sounds::SFX_LevelUp.play if speed_level_from_rows > @speed_level
    @speed_level = [@speed_level, speed_level_from_rows].max
  end
end
