task :default => :test

desc "Run the rules tests under MRI"
task :test do
  Dir.glob('./test/core/test_*.rb').each { |file| require file }
end
