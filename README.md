# Advent of Code 2021

Solutions for https://adventofcode.com/2021.

All the puzzles are solved with Ruby 💎

## Running time

This is just to get a rough idea of how the code performs.

The numbers are the `total` reading from running `time` command on my local machine (a regular MacBook Air).

Unit is second.

- Day  1: 0.180
- Day  2: 0.149
- Day  3: 0.151
- Day  4: 0.155
- Day  5: 0.480
- Day  6: 0.149
- Day  7: 0.325
- Day  8: 0.166
- Day  9: 0.172
- Day 10: 0.151
- Day 11: 0.301
- Day 12: 1.036
- Day 13: 0.199
- Day 14: 0.179
- Day 15: 4299 -> 11.98
- Day 16: 0.169
- Day 17: 0.181
- Day 16: 1.838



## Some automated tasks

There are two tasks defined in Rakefile: `start` and `run`.
- `rake start [day_num]`
  - Create a new file from template.rb for the day.
  - Download the input file into data/ directory.
  - If no argument is provided, `day_num` defaults to the current day.
  - Needs an environmental variable `AOC_SESSION_TOKEN` to fetch the input data.
- `rake run [source_code_path]`
  - Run the code in `source_code_path` and print the result.
  - If no argument is provided, `source_code_path` defaults to the path of current day's puzzle.
