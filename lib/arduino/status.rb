module FB
  class Status
    # Map of informational status and default values for status within Arduino.
    DEFAULT_INFO = {X: 0, Y: 0, Z: 0, S: 10, Q: 0,  T: 0,  C: '', P: 0,  V: 0,
                    W: 0, L: 0, E: 0, M: 0, XA: 0, XB: 0, YA: 0, YB: 0, ZA: 0,
                   ZB: 0, busy: 1}
    # Put it into a struct.
    Info = Struct.new(*DEFAULT_INFO.keys)

    attr_reader :bot

    def initialize(bot)
      @bot, @info = bot, Info.new(*DEFAULT_INFO.values)
    end

    def []=(register, value)
      # Add event broadcasts here!!!
      @info[value.upcase.to_sym] = value
    end

    def [](value)
      @info[value.upcase.to_sym]
    end
  end
end
