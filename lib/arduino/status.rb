module FB
  class Status
    # Map of informational status and default values for status within Arduino.
    DEFAULT_INFO = {X: 0, Y: 0, Z: 0, S: 10, Q: 0,  T: 0,  C: '', P: 0,  V: 0,
                    W: 0, L: 0, E: 0, M: 0, XA: 0, XB: 0, YA: 0, YB: 0, ZA: 0,
                   ZB: 0,YR: 0, R: 0, BUSY: 1}
    Info = Struct.new(*DEFAULT_INFO.keys)

    def initialize
      @changes = EM::Channel.new
      @info    = Info.new(*DEFAULT_INFO.values)
    end

    def transaction(&blk)
      old = @info.to_h
      yield(@info)
      # Broadcast a diff between the old status and new status
      diff = (@info.to_h.to_a - old.to_a).to_h
      @changes << diff unless diff.empty?
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

    def onchange
      @changes.subscribe { |diff| yield(diff) }
    end

    def ready?
      self[:BUSY] == 0
    end
  end
end
