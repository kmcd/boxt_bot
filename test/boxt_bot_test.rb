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

  def assert_orientation(orientation, robot)
    assert_equal orientation, robot.orientation
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
    assert_placed(@robot, 0, 0)

    @robot.place 5, 4, :north
    assert_placed(@robot, 0, 0)
  end

  test "place with valid orientations" do
    @robot.place 0, 0, :north
    assert_orientation("north", @robot)

    @robot.place 0, 0, :south
    assert_orientation("south", @robot)

    @robot.place 0, 0, :east
    assert_orientation("east", @robot)

    @robot.place 0, 0, :west
    assert_orientation("west", @robot)
  end

  test "place with invalid orientations does not change orientation" do
    @robot.place 0, 0, :foo
    assert_nil(@robot.orientation)
    assert_nil(@robot.position)

    @robot.place 0, 0, :north
    @robot.place 0, 0, :foo
    assert_orientation("north", @robot)
  end

  test "change orientation 90 degrees to the left" do
    @robot.place 0, 0, :north

    @robot.left
    assert_orientation("west", @robot)

    @robot.left
    assert_orientation("south", @robot)
  end

  test "change orientation 90 degrees to the right" do
    @robot.place 0, 0, :north

    @robot.right
    assert_orientation("east", @robot)

    @robot.right
    assert_orientation("south", @robot)
  end

  test "move one position with correct orientation" do
    # south west corner
    @robot.place 0, 0, :north
    @robot.move
    assert_placed(@robot, 0, 1)

    @robot.place 0, 0, :east
    @robot.move
    assert_placed(@robot, 1, 0)

    # north west corner
    @robot.place 0, 4, :south
    @robot.move
    assert_placed(@robot, 0, 3)

    @robot.place 0, 4, :east
    @robot.move
    assert_placed(@robot, 1, 4)

    # north east corner
    @robot.place 4, 4, :south
    @robot.move
    assert_placed(@robot, 4, 3)

    @robot.place 4, 4, :west
    @robot.move
    assert_placed(@robot, 3, 4)

    # south east corner
    @robot.place 4, 0, :north
    @robot.move
    assert_placed(@robot, 4, 1)

    @robot.place 4, 0, :west
    @robot.move
    assert_placed(@robot, 3, 0)
  end

  test "move one position with incorrect orientation" do
    # south west corner
    @robot.place 0, 0, :south
    @robot.move
    assert_placed(@robot, 0, 0)

    @robot.place 0, 0, :west
    @robot.move
    assert_placed(@robot, 0, 0)

    # north west corner
    @robot.place 0, 4, :north
    @robot.move
    assert_placed(@robot, 0, 4)

    @robot.place 0, 4, :west
    @robot.move
    assert_placed(@robot, 0, 4)

    # north east corner
    @robot.place 4, 4, :north
    @robot.move
    assert_placed(@robot, 4, 4)

    @robot.place 4, 4, :east
    @robot.move
    assert_placed(@robot, 4, 4)

    # south east corner
    @robot.place 4, 0, :south
    @robot.move
    assert_placed(@robot, 4, 0)

    @robot.place 4, 0, :east
    @robot.move
    assert_placed(@robot, 4, 0)
  end

  test "wait for valid placement before moving" do
    @robot.move
    assert_nil @robot.position
  end

  test "wait for valid placement before changing orientation" do
    @robot.left
    assert_nil @robot.orientation

    @robot.right
    assert_nil @robot.orientation
  end
end

class BoxtBot::SimulationTest < ActiveSupport::TestCase
  def run_simulation(name)
    file = File.open File.expand_path("../../test/fixtures/#{name}.txt", __FILE__)
    simulation = BoxtBot::Simulation.new file: file
    capture_io { simulation.run }.first.split "\n"
  end

  test "report current position and orientation to stdout" do
    stdout = run_simulation "simulation_01"
    assert_equal ["0,1,NORTH"], stdout
  end

  test "run movement simulation" do
    stdout = run_simulation "simulation_02"
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

    position = @table_top.place(1, 1)

    assert_equal 1, position.y
    assert_equal 1, position.x
  end

  test "gracefully handle invalid position placement" do
    assert_nil @table_top.place(-1, -1)
    assert_nil @table_top.place(0, 5)
    assert_nil @table_top.place(5, 0)
    assert_nil @table_top.place(5, 5)
  end
end
