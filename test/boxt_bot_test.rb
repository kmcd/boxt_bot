require "test_helper"

class BoxtBotTest < ActiveSupport::TestCase
  test "that it has a version number" do
    refute_nil ::BoxtBot::VERSION
  end
end

class BoxtBot::RobotTest < ActiveSupport::TestCase
  setup do
    @robot = BoxtBot::Robot.new
  end

  def assert_placed(robot, x, y)
    assert_equal BoxtBot::Position.new(x, y), @robot.position
  end

  def assert_orientation(orientatation, robot)
    assert_equal orientatation, robot.orientatation
  end

  test "place at origin" do
    @robot.place 0, 0, :north
    assert_placed(@robot, 0, 0)
  end

  test "place in valid positions" do
    @robot.place 0, 1, :north
    assert_placed(@robot, 0, 1)

    @robot.place 1, 0, :north
    assert_placed(@robot, 1, 0)

    @robot.place 1, 1, :north
    assert_placed(@robot, 1, 1)
  end

  test "place in invalid position maintains existing position" do
    @robot.place 0, 0, :north
    @robot.place 2, 2, :north
    assert_placed(@robot, 0, 0)

    @robot.place(-1, -1, :north)
    assert_placed(@robot, 0, 0)
  end

  test "place with valid orientatations" do
    @robot.place 0, 0, :north
    assert_orientation("north", @robot)

    @robot.place 0, 0, :south
    assert_orientation("south", @robot)

    @robot.place 0, 0, :east
    assert_orientation("east", @robot)

    @robot.place 0, 0, :west
    assert_orientation("west", @robot)
  end

  test "place with invalid orientatations does not change orientatation" do
    @robot.place 0, 0, :foo
    assert_nil(@robot.orientatation)
    assert_nil(@robot.position)

    @robot.place 0, 0, :north
    @robot.place 0, 0, :foo
    assert_orientation("north", @robot)
  end

  test "change orientatation 90 degrees to the left" do
    @robot.place 0, 0, :north

    @robot.left
    assert_orientation("west", @robot)

    @robot.left
    assert_orientation("south", @robot)
  end

  test "change orientatation 90 degrees to the right" do
    @robot.place 0, 0, :north

    @robot.right
    assert_orientation("east", @robot)

    @robot.right
    assert_orientation("south", @robot)
  end

  test "move one position with correct orientatation" do
    @robot.place 0, 0, :north
    @robot.move
    assert_placed(@robot, 0, 1)

    @robot.place 0, 0, :east
    @robot.move
    assert_placed(@robot, 1, 0)

    @robot.place 0, 1, :south
    @robot.move
    assert_placed(@robot, 0, 0)

    @robot.place 0, 1, :east
    @robot.move
    assert_placed(@robot, 1, 1)

    @robot.place 1, 1, :south
    @robot.move
    assert_placed(@robot, 1, 0)

    @robot.place 1, 1, :west
    @robot.move
    assert_placed(@robot, 0, 1)
  end

  test "move one position with incorrect orientatation" do
    @robot.place 0, 0, :south
    @robot.move
    assert_placed(@robot, 0, 0)

    @robot.place 0, 0, :west
    @robot.move
    assert_placed(@robot, 0, 0)

    @robot.place 0, 1, :north
    @robot.move
    assert_placed(@robot, 0, 1)

    @robot.place 0, 1, :west
    @robot.move
    assert_placed(@robot, 0, 1)

    @robot.place 1, 1, :north
    @robot.move
    assert_placed(@robot, 1, 1)

    @robot.place 1, 1, :east
    @robot.move
    assert_placed(@robot, 1, 1)
  end

  test "wait for valid placement before moving" do
    @robot.move
    assert_nil @robot.position
  end

  test "wait for valid placement before changing orientation" do
    @robot.left
    assert_nil @robot.orientatation

    @robot.right
    assert_nil @robot.orientatation
  end
end

class BoxtBot::SimulationTest < ActiveSupport::TestCase
  def run_simulation(name, size: 2)
    file = File.open File.expand_path("../../test/fixtures/#{name}.txt", __FILE__)
    simulation = BoxtBot::Simulation.new file: file, size: size
    capture_io { simulation.run }.first.split "\n"
  end

  test "report current position and orientatation to stdout" do
    stdout = run_simulation "simulation_01"
    assert_equal ["0,1,NORTH"], stdout
  end

  test "run 5x5 example simulation" do
    stdout = run_simulation "simulation_02", size: 5
    assert_equal ["0,1,NORTH", "0,0,WEST", "3,3,NORTH"], stdout
  end
end

class BoxtBot::TableTopTest < ActiveSupport::TestCase
  setup do
    @table_top = BoxtBot::TableTop.new
  end

  test "place at position" do
    position = @table_top.place(0, 0)

    assert_equal 0, position.y
    assert_equal 0, position.x
  end

  test "gracefully handle invalid position placement" do
    assert_nil @table_top.place(-1, -1)
    assert_nil @table_top.place(0, 2)
    assert_nil @table_top.place(2, 0)
  end
end
