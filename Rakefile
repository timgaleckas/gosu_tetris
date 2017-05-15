task :default => :test
task :test do
  Dir.glob('./test/test_*.rb').each { |file| require file}
end

task :generate_sprites do
  Dir.glob('./sprite_generation/test/test_*.rb').each { |file| require file}
end

task :package do
  require 'plist'
  require_relative './lib/app'
  FileUtils.rm_rf App.root / 'package'
  FileUtils.mkdir_p App.root / 'package'

  package_root = App.root/'package'
  puts `unzip #{App.root/'packaging'/'Ruby.zip'} -d #{package_root}`

  app_file = package_root/'Ruby.app'
  p_list_file = app_file/'Contents'/'Info.plist'
  p_list = Plist::parse_xml p_list_file
  p_list['CFBundleIdentifier'] = 'com.galeskies.Timtris'
  File.open(p_list_file, 'w'){|file| file.write(p_list.to_plist)}

  package_ruby_root = package_root/'Ruby.app'/'Contents'/'Resources'
  FileUtils.cp_r(App.root/'lib',package_ruby_root/'main')
  FileUtils.cp_r(App.root/'assets',package_ruby_root/'assets')
  FileUtils.cp(App.root/'Gemfile',package_ruby_root)
  FileUtils.cp(App.root/'Gemfile.lock',package_ruby_root)

  File.open(package_ruby_root/'.ruby-version', 'w') do |file|
    file.write("2.4.1")
  end
  Bundler.with_clean_env do
    puts `cd #{package_ruby_root} && BUNDLE_IGNORE_CONFIG=1 bundle install --without=development --deployment --path lib`
  end
  FileUtils.cp_r(Dir.glob(package_ruby_root/'lib'/'ruby'/'*'/'gems'/'*'/'lib'/'*'), package_ruby_root/'lib')
  File.open(package_ruby_root/'main.rb', 'w') do |file|
    file.write(<<-MAIN)
require_relative './main/app'
TetrisWindow.new.show
    MAIN
  end
  FileUtils.mv(app_file,package_root/'Timtris.app')
end
