class Sounds
  # Samples keyed by file name; files are lowercase, names from the rules may not be.
  SAMPLES = Dir.glob((App.asset_root / 'sounds' / '*.ogg').to_s).to_h do |f|
    [File.basename(f, '.ogg'), Gosu::Sample.new(f)]
  end

  # Audio for the rules: plays the sample named after its file in assets/sounds.
  def self.play(name)
    SAMPLES.fetch(name.downcase).play
  end
end
