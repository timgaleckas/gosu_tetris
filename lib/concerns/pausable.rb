require 'active_support/concern'

module Pausable
  extend ActiveSupport::Concern

  included do
    def self.pausable(method)
      alias_method "#{method}_without_pausing", method
      define_method method do |*args|
        unless @game_state.paused?
          send "#{method}_without_pausing", *args
        end
      end
    end
  end
end
