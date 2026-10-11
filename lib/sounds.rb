class Sounds
  Dir.glob((App.asset_root / 'sounds' / '*.ogg').to_s).each do |f|
    const_set(File.basename(f, '.ogg'), Gosu::Sample.new(f))
  end

  # Audio for the rules: plays the sample named after its file in assets/sounds.
  def self.play(name)
    const_get(name).play
  end
end
