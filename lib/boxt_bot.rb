require "boxt_bot/version"
require "active_support/all"

module BoxtBot
  class Robot
    attr_reader :compass, :position, :table_top

    def initialize(table_top = BoxtBot::TableTop.new)
      @table_top = table_top
      @compass = %w[north east south west]
    end

    def left
      compass.rotate!(-1) if position.present?
    end

    def right
      compass.rotate!(1) if position.present?
    end

    def orientatation
      compass.first if position.present?
    end

    def place(x, y, point)
      return unless placement_valid?(x, y, point)

      change_position(x, y)
      change_orientation(point)
    end

    def move
      return unless position.present?

      case orientatation
      when /north/i then change_position(position.x, position.y + 1)
      when /south/i then change_position(position.x, position.y - 1)
      when /east/i then change_position(position.x + 1, position.y)
      when /west/i then change_position(position.x - 1, position.y)
      end
    end

    def to_s
      return unless position.present?

      [position.x, position.y, orientatation.upcase].join ","
    end

    private

    def change_position(x, y)
      return unless (position = table_top.place(x, y))

      @position = position
    end

    def change_orientation(point)
      right until orientatation == point.to_s
    end

    def placement_valid?(x, y, point)
      return unless table_top.place(x, y).present?

      compass.include?(point.to_s)
    end
  end

  class Simulation
    attr_reader :commands

    def initialize(file:, size: 2)
      @commands = file.readlines
      @robot = BoxtBot::Robot.new BoxtBot::TableTop.new size: size
    end

    def run
      commands.each do |command|
        case command
        when /^left$/i then @robot.left
        when /^move$/i then @robot.move
        when /^place\s+(\d+),(\d+),(\w+)$/i then @robot.place($1.to_i, $2.to_i, $3.downcase)
        when /^report$/i then $stdout.puts(@robot.to_s) if @robot.to_s
        when /^right$/i then @robot.right
        end
      end
    end
  end

  class TableTop
    attr_reader :positions

    def initialize(size: 2)
      @positions = Array.new(size) do |x|
        Array.new(size) do |y|
          Position.new(x, y)
        end
      end.reverse.flatten
    end

    def place(x, y)
      @positions.find do |position|
        position.y == y && position.x == x
      end
    end
  end

  class Position
    attr_reader :x, :y

    def initialize(x, y)
      @x, @y = x, y
    end

    def ==(other)
      other.y == y && other.x == x
    end
  end
end
