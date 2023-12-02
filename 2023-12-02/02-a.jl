using Logging

# debug_logger = ConsoleLogger(stderr, Logging.Debug)
debug_logger = ConsoleLogger(stderr, Logging.Error)
global_logger(debug_logger)

dict = Dict("red" => 1, "green" => 2, "blue" => 3)
n_rgb = [12, 13, 14]

# filename = "2023-12-02/02-a-test.txt"
filename = "2023-12-02/02-a-input.txt"
lines = readlines(filename)
running_total = 0
for (index, line) in enumerate(lines)
    games = split(split(line, ":")[2], ";")
    possible = true
    for game in games
        rgb = [0, 0, 0]
        cubes = split(game, ",")
        for cube in cubes
            n_col = split(cube, " ")
            rgb[dict[n_col[3]]] += parse(Int, n_col[2])
        end
        if (rgb .> n_rgb) != [false, false, false]
            possible = false
        end
    end
    if possible
        running_total += index
    end
end
print("Total = ", running_total)
