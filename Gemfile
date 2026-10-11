# frozen_string_literal: true
source "https://rubygems.org"

gem "gosu"
gem "commander"

group :development do
  gem "rake"
  gem "minitest"
  gem "plist"
end

# Only needed to regenerate sprites (rake generate_sprites); requires ImageMagick.
group :sprites, optional: true do
  gem "rmagick"
end
