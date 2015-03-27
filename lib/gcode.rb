require 'yaml'
module FB
  class Gcode
    attr_accessor :cmd, :params, :str

    def initialize(str)
      @str = str
      @params = str.split(' ').map{|line| GcodeToken.new(line)}
      @cmd = @params.shift
    end

    def self.parse_lines(string)
      string.gsub("\r", '').split("\n").map { |s| self.new(s) }
    end

    # Seperate head of Params / Gcode from the 'tails'
    class GcodeToken
      attr_reader :head, :tail, :name

      def initialize(str)
        nodes = str.scan(/\d+|\D+/) # ["R", "01"]
        @head, @tail = nodes.shift.to_sym, nodes
      end
    end
  end
end
