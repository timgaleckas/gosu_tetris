# Choices kept between games and sessions: the starting levels for each mode and the
# volume. Saved to settings.txt in DragonRuby's save area (browser storage on the web).
module Settings
  FILE = 'settings.txt'.freeze
  DEFAULTS = { classic_speed: 0, next_speed: 0, next_stage: 2, volume: 10 }.freeze

  def self.[](key)
    _values.fetch(key)
  end

  def self.[]=(key, value)
    _values[key] = value
    _save
  end

  def self._values
    @values ||= _load
  end

  def self._load
    values = DEFAULTS.dup
    text = begin
      GTK.read_file(FILE)
    rescue Exception
      nil
    end
    text.to_s.split("\n").each do |line|
      key, value = line.strip.split('=', 2)
      values[key.to_sym] = value.to_i if key && value && values.key?(key.to_sym)
    end
    values
  end

  def self._save
    GTK.write_file(FILE, @values.map { |key, value| "#{key}=#{value}\n" }.join)
  rescue Exception
    nil
  end
end
