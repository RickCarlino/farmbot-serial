module FB
  class Status
    GCODE_NAMES ||= YAML.load_file(File.join(File.dirname(__FILE__), 'gcode.yml'))
    # Status registers for device state. SEE: Param.yml
    DEFAULT_INFO = {X: 0, Y: 0, Z: 0, S: 10, Q: 0, T: 0, C: '', P: 0, V: 0,
                    W: 0, L: 0, E: 0, M: 0, XA: 0, XB: 0, YA: 0, YB: 0, ZA: 0,
                   ZB: 0}
    Info = Struct.new(*DEFAULT_INFO.keys)

    def initialize(bot)
      @bot, @info = bot, Info.new(*DEFAULT_INFO.values)
    end

    def parse_incoming(gcode)
      gcode.params.each { |p| @info[p.head] = p.tail if p.tail }
    end
  end
end
