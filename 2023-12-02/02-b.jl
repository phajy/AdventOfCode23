using Logging

debug_logger = ConsoleLogger(stderr, Logging.Debug)
# debug_logger = ConsoleLogger(stderr, Logging.Error)
global_logger(debug_logger)

dict = Dict("red" => 1, "green" => 2, "blue" => 3)

# filename = "2023-12-02/02-a-test.txt"
filename = "2023-12-02/02-a-input.txt"
lines = readlines(filename)
running_total = 0
for (index, line) in enumerate(lines)
    games = split(split(line, ":")[2], ";")
    n_rgb = [0, 0, 0]
    for game in games
        rgb = [0, 0, 0]
        cubes = split(game, ",")
        for cube in cubes
            n_col = split(cube, " ")
            rgb[dict[n_col[3]]] += parse(Int, n_col[2])
        end
        indices = findall(rgb .> n_rgb)
        n_rgb[indices] = rgb[indices]
    end
    power = n_rgb[1] * n_rgb[2] * n_rgb[3]
    @debug line, n_rgb, power
    running_total += power
end
print("Total power = ", running_total)
