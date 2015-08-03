module FB
  class Status
    # Map of informational status and default values for status within Arduino.
    DEFAULT_INFO = {X: 0, Y: 0, Z: 0, S: 10, BUSY: 1, LAST: 'none'}

    def initialize
      @changes = EM::Channel.new
      @info    = OpenStruct.new(DEFAULT_INFO)
    end

    def transaction(&blk)
      old = @info.to_h
      yield(@info)
      # Broadcast a diff between the old status and new status
      diff = (@info.to_h.to_a - old.to_a).to_h
      @changes << diff unless diff.empty?
    end

    def []=(register, value)
      transaction { @info[register.to_s.upcase] = value }
    end

    def [](value)
      @info[value.upcase.to_s]
    end

    def to_h
      @info.to_h
    end

    def gcode_update(gcode)
      transaction do
        gcode.params.each { |p| @info[p.head] = p.tail }
      end
    end

    def onchange
      @changes.subscribe { |diff| yield(diff) }
    end

    def ready?
      self[:BUSY] == 0
    end

    def get(val)
      @info[val.to_s.upcase] || :unknown
    end

    def set(key, val)
      transaction do |info|
        info[Gcode::PARAMETER_DICTIONARY.fetch(key, key.to_s)] = val
      end
    end

    def pin(num)
      case get(num)
      when false, 0, :off then :off
      when true, 1, :on then :on
      else; :unknown
      end
    end
  end
end
