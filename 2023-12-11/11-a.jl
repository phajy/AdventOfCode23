using DelimitedFiles
using Logging

debug_logger = ConsoleLogger(stderr, Logging.Error)
global_logger(debug_logger)

# filename = "2023-12-11/11-test.txt"
filename = "2023-12-11/11-input.txt"

input_file = readdlm(filename)
input_file = reverse(input_file)

x_size = length(input_file[1])
y_size = length(input_file)
sky = fill('.', x_size, y_size)
empty_rows = fill(true, y_size)
empty_columns = fill(true, x_size)
galaxies = []
for y in range(y_size, 1, step = -1)
    for x in range(1, x_size)
        sky[x, y] = input_file[y][x]
        if sky[x, y] == '#'
            empty_rows[y] = false
            empty_columns[x] = false
            push!(galaxies, (x, y))
        end
    end
end

# show the sky
# for y in range(y_size, 1, step=-1)
#     for x in range(1, x_size)
#         print(sky[x, y])
#     end
#     println()
# end

# calculate distances between pairs of galaxies
s = 0
for (index, galaxy) in enumerate(galaxies)
    for (second_index, second_galaxy) in enumerate(galaxies[1:index-1])
        x_range = sort([galaxy[1], second_galaxy[1]])
        Δx = x_range[2] - x_range[1]
        Δx += count(empty_columns[x_range[1]:x_range[2]])
        y_range = sort([galaxy[2], second_galaxy[2]])
        Δy = y_range[2] - y_range[1]
        Δy += count(empty_rows[y_range[1]:y_range[2]])
        Δs = Δx + Δy
        @debug "Galaxy " *
               string(index) *
               " to " *
               string(second_index) *
               " is " *
               string(Δs)
        s += Δs
    end
end
println("Total distance: ", s)
