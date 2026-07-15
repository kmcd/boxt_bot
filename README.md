# BoxtBot

BOXT simulation robot.

**N.B.** Written without any LLM assistance.

## Installation

After checking out the repo locally, run `bundle install` to install dependencies.

Then, run `rake test` to run the test suite.

You can also run `bin/console` for an interactive prompt that will allow you to experiment.

## Usage

You can run a simulation by passing a test file path:

```bash
bin/simulation SIMULATION_FILE_PATH
```

For example:

```bash
bin/simulation test/fixtures/simulation_01.txt
0,1,NORTH
```

```bash
bin/simulation test/fixtures/simulation_02.txt
0,1,NORTH
0,0,WEST
3,3,NORTH
```

## Notes

Kept all logic in `./lib/boxt_bot.rb` to speed things up. Usually I'd have one
class per file. Same applies to `./test/boxt_bot_test.rb`.

`BoxtBot::TableTop` does not validate the initialize size argument. As this is
not passed from user input or dynamically assigned, I think this is acceptable
for this exercise. Invalid sizes (e.g. `-1`, `a` etc.) will raise an exception, which I'm assuming is a development (not run) time concern.