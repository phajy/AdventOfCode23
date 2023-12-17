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
- 10: Part A bit more awkward than anticipated. Part B forgot to replace the starting point when looking for enclosed spaces.
- 11: `reverse`. `count` can be used to count numbers `true`'s in an array.
- 12: Strings are immutable. Who knew? Also `Threads.@threads` (but don't need this with an efficient code!). Memoization. Lots to learn with this one!
- 13: `transpose`.
- 14: Easy to be out of phase by ±1 if not careful.
- 15: [Comprehensions and generators](https://docs.julialang.org/en/v1/manual/arrays/#man-comprehensions).
- 16:
