# BoxtBot

BOXT simulation robot.

**N.B.** Written without any LLM assistance.

## Installation

After checking out the repo locally, run `bundle install` to install dependencies.

Then, run `rake test` to run the test suite.

You can also run `bin/console` for an interactive prompt that will allow you to experiment.

## Usage

You can run a simulation by passing a mandatory test file path.

```bash
bin/simulation SIMULATION_FILE_PATH
```

## Simulation Examples

Test invalid placements before initial movement:

```bash
bin/simulation test/fixtures/simulation_01.txt
0,1,NORTH
```

Test movement and placements:

```bash
bin/simulation test/fixtures/simulation_02.txt
0,1,NORTH
0,0,WEST
3,3,NORTH
```

Start at 0,0 facing north and move right (clockwise)

```bash
bin/simulation test/fixtures/simulation_03.txt
0,1,NORTH
1,1,EAST
1,0,SOUTH
0,0,WEST
```

## Notes

Kept all logic in `./lib/boxt_bot.rb` to . Usually I'd have one
class per file. Same applies to `./test/boxt_bot_test.rb`.

`bin/simulation` does not use switches or validate arguments.