require 'yaml'
module FB
  class Gcode
    attr_accessor :code, :params, :str

    def initialize(str)
      @str = str
      @params = str.split(' ').map{|line| GcodeToken.new(line)}
      @code = @params.shift
    end

    # Seperate head of Params / Gcode from the 'tails'
    class GcodeToken
      attr_reader :head, :tail, :name
      def initialize(str)
        nodes = str.scan(/\d+|\D+/) # ["R", "01"]
        @head, @tail = nodes.shift, nodes
      end
    end
  end
end
