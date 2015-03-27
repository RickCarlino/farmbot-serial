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

    def parse_incoming(gcode) # gcode is an actual Gcode object, not String.
      # This method will always be the first in line to send a bot a message
      # and control traffic. Default business status is 1.
      case gcode.status_effect
      when :done;     self[:busy] = 0
      when :received; self[:busy] = 1
      when :busy;     self[:busy] = 1
      when :error;    raise HardwareError # We should treat errors like errors.
      else;           business_as_usual   # Not a real method. Could be, though.
      end
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
