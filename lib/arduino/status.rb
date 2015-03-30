module FB
  class Status
    # Map of informational status and default values for status within Arduino.
    DEFAULT_INFO = {X: 0, Y: 0, Z: 0, S: 10, Q: 0,  T: 0,  C: '', P: 0,  V: 0,
                    W: 0, L: 0, E: 0, M: 0, XA: 0, XB: 0, YA: 0, YB: 0, ZA: 0,
                   ZB: 0,YR: 0, R: 0, BUSY: 1}
    # Put it into a struct.
    Info = Struct.new(*DEFAULT_INFO.keys) do
      def to_h
        # So here's the deal: Ruby 2.2.0 has a to_h method, but raspbian ships
        # with 1.9.3 by default. Compiling 2.2.0 on a pi takes HOURS, so I am
        # going to reinvent the wheel in the name of saving users installation
        # time.
        Hash[each_pair.to_a]
      end
    end

    attr_reader :bot

    def initialize(bot)
      @bot, @info = bot, Info.new(*DEFAULT_INFO.values)
    end

    def transaction(&blk)
      old = @info.to_h
      yield
      emit_updates(old)
    end

    def []=(register, value)
      transaction { @info[register.upcase.to_sym] = value }
    end

    def [](value)
      @info[value.upcase.to_sym]
    end

    def gcode_update(gcode)
      transaction do
        gcode.params.each { |p| @info.send("#{p.head}=", p.tail) }
      end
    end

    def emit_updates(old)
      # calculate a diff between the old status and new status
      changes = (@info.to_h.to_a - old.to_a).to_h
      bot.log "STATUS UPDATE: #{changes}" unless changes.empty?
    end
  end
end
