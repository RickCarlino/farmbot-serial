require 'yaml'
module FB
  class Gcode
    GCODE_DICTIONARY = YAML.load_file(File.join(File.dirname(__FILE__), 'gcode.yml'))

    attr_accessor :cmd, :params, :str

    def initialize(str)
      @str = str
      @params = str.split(' ').map{|line| GcodeToken.new(line)}
      @cmd = @params.shift
    end

    # Turns a string of many gcodes into an array of many gcodes. Used to parse
    # incoming serial.
    def self.parse_lines(string)
      string.gsub("\r", '').split("\n").map { |s| self.new(s) }
    end

    # Returns a symbolized english version of the gcode's name.
    def name
      GCODE_DICTIONARY[cmd.to_sym] || :unknown
    end

    # A head/tail pair of a single node of GCode. Ex: R01 = [:R, '01']
    class GcodeToken
      attr_reader :head, :tail, :name

      def initialize(str)
        nodes = str.scan(/\d+|\D+/) # ["R", "01"]
        @head, @tail = nodes.shift.to_sym, nodes.join(" ")
      end

      def to_sym
        "#{head}#{tail}".to_sym
      end
    end
  end
end
