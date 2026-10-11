# Wraps methods so they do nothing while the including object's suspended? is true.
module Suspendable
  def self.included(base)
    base.extend(ClassMethods)
  end

  module ClassMethods
    def suspendable(method)
      alias_method "#{method}_without_suspending", method
      define_method method do |*args|
        unless suspended?
          send "#{method}_without_suspending", *args
        end
      end
    end
  end
end
