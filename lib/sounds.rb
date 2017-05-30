class Sounds
  Dir.glob(App.asset_root / 'sounds' / '*.ogg').each do |f|
    const_set(File.basename(f, '.ogg'), Gosu::Sample.new(f))
  end

  PRAISES = [
    VO_AMAZING,
    VO_BRILLIANT,
    VO_EXLNT,
    VO_FANTSTC,
    VO_THTGREAT,
    VO_VRYGOOD,
    VO_WONDRFL,
    VO_WOW
  ]
end
