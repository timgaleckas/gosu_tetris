require_relative '../core_helper'
require 'rbconfig'

describe "lib/core" do
  it "loads and plays without Gosu or any gems" do
    core = File.expand_path('../../lib/core', __dir__)
    script = "require #{core.inspect}; g = Game.new(GameState.new); 600.times { g.update }; " \
             "print [defined?(Gosu), defined?(ActiveSupport)].compact.inspect"
    output = IO.popen([RbConfig.ruby, '--disable-gems', '-e', script], err: [:child, :out], &:read)
    _(output).must_equal '[]'
  end
end
