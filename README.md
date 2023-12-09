# AdventOfCode23

[Advent of Code](https://adventofcode.com) 2023. Solutions in Julia.

# Lessons from each day

(an idea copied from Fergus's [Advent of Code 2023](https://github.com/fjebaker/advent-of-code-2023))

- 01: Can `match` regular expressions.
- 02: A dictionary, `Dict`, was helpful.
- 03: `checkbounds` to check array bounds. Can use `∉` which is nice.
- 04: CSV reader has a boolean option `ignorerepeated`.
- 05: It can be annoying doing part A before part B - ha ha. Need to get better at using the "!" convention in function names that mutate their arguments. This one was tricky!
- 06: Shameless brute force solution as an antidote to 05. Used `replace` to get rid of the spaces.
- 07: Sorting.
- 08: Mapping file didn't start at AAA. [`lcm`](https://docs.julialang.org/en/v1/base/math/#Base.lcm) - yay! And `falses`.
- 09: `pushfirst!`