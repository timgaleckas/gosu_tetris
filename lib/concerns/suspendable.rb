require 'active_support/concern'

module Suspendable
  extend ActiveSupport::Concern

  included do
    def self.suspendable(method)
      alias_method "#{method}_without_suspending", method
      define_method method do |*args|
        unless suspended?
          send "#{method}_without_suspending", *args
        end
      end
    end
  end
end
