# The rules play sounds by name through an object responding to play(name).
# Names match the files in assets/sounds.
module Audio
  PRAISES = %w[
    VO_AMAZING
    VO_BRILLIANT
    VO_EXLNT
    VO_FANTSTC
    VO_THTGREAT
    VO_VRYGOOD
    VO_WONDRFL
    VO_WOW
  ].freeze

  class Silent
    def play(_name)
    end
  end
end
