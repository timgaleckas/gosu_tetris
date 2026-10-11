require_relative '../core_helper'

# Both frontends play the rules' sounds from assets/sounds/<name, lowercased>.ogg.
describe "sound assets" do
  it "exist for every sound the rules play" do
    sources = Dir.glob(File.expand_path('../../lib/core/**/*.rb', __dir__)).map { |f| File.read(f) }.join
    names = sources.scan(/'(SFX_\w+)'/).flatten.uniq + Audio::PRAISES
    _(names.size).must_be :>, 8
    missing = names.reject { |name| File.exist?(File.expand_path("../../assets/sounds/#{name.downcase}.ogg", __dir__)) }
    _(missing).must_be_empty
  end
end
