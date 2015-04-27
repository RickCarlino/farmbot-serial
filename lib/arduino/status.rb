module FB
  class Status
    # Map of informational status and default values for status within Arduino.
    DEFAULT_INFO = {X: 0, Y: 0, Z: 0, S: 10, BUSY: 1, LAST: 'none', PINS: {}}
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
      transaction do
        register = register.upcase.to_sym
        @info[register] = value if @info.members.include?(register)
      end
    end

    def [](value)
      @info[value.upcase.to_sym]
    end

    def gcode_update(gcode)
      transaction do
        gcode.params.each do |p|
          setter = "#{p.head}="
          @info.send(setter, p.tail) if @info.respond_to?(setter)
        end
      end
    end

    def onchange
      @changes.subscribe { |diff| yield(diff) }
    end

    def ready?
      self[:BUSY] == 0
    end

    def pin(num)
      @info[:PINS][num] || :unknown
    end

    def set_pin(num, val)
      val = [true, 1, '1'].include?(val) ? :on : :off
      transaction { |info| info.PINS[num] = val }
    end
  end
end
