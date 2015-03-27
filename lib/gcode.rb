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

    # Determine if the current Gcode is one that affects the bot's availability
    # status.
    def status_changer?
      status_effect != :none
    end

    def status_effect
      case (@cmd.head == :R) && cmd.tail.to_i
      when 1; :received
      when 2; :done
      when 3; :error
      when 4; :busy
      else;   :none
      end
    end

    # Seperate head of Params / Gcode from the 'tails'
    class GcodeToken
      attr_reader :head, :tail, :name

      def initialize(str)
        nodes = str.scan(/\d+|\D+/) # ["R", "01"]
        @head, @tail = nodes.shift.to_sym, nodes.join(" ")
      end
    end
  end
end
