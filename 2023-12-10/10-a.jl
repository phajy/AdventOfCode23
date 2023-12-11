using DelimitedFiles
using Logging

debug_logger = ConsoleLogger(stderr, Logging.Error)
global_logger(debug_logger)

# filename = "2023-12-10/10-test.txt"
filename = "2023-12-10/10-input.txt"

input_file = readdlm(filename)

# Create a 2D array of individual characters
char_array = [collect(string(x)) for x in input_file]

x_size = length(char_array[1])
y_size = length(char_array)
start_x = 0
start_y = 0

mappings = fill((0, 0, 0, 0), x_size, y_size)

maps = [('|', 0, 1, 0, -1), ('-', 1, 0, -1, 0), ('L', 0, 1, 1, 0), ('J', 0, 1, -1, 0), ('7', 0, -1, -1, 0), ('F', 0, -1, 1, 0)]

# Create a mapping, find start point, create picture
# Bottom left is (1, 1)
for x in range(1, x_size)
    for y in range(1, y_size)
        character = char_array[y_size-y+1][x]
        if character == 'S'
            start_x = x
            start_y = y
        end
        for cur_map in maps
            if character == cur_map[1]
                mappings[x, y] = (cur_map[2], cur_map[3], cur_map[4], cur_map[5])
            end
        end
    end
end

# figure out what to replace S with (we know there should only be two connections)
# character displacement_1 direction_1 dispalcement_2 direction_2
@debug "start x = " * string(start_x) * " start y = " * string(start_y)
for replace in maps
    # if this is a good replacement there should be equal and opposite pipes
    ok = 0
    for dir in (2, 4)
        # see where we should look
        Δx = replace[dir]
        Δy = replace[dir+1]
        check_x = start_x + Δx
        check_y = start_y + Δy
        @debug replace[1], check_x, check_y, Δx, Δy
        if check_x >= 1 && check_x <= x_size && check_y >= 1 && check_y <= y_size
            if (mappings[check_x, check_y][1] == -Δx && mappings[check_x, check_y][2] == -Δy) || (mappings[check_x, check_y][3] == -Δx && mappings[check_x, check_y][4] == -Δy)
                ok += 1
            end
        end
    end
    @debug " ok = " * string(ok)
    if ok == 2
        @debug "Replace S with " * replace[1]
        mappings[start_x, start_y] = (replace[2], replace[3], replace[4], replace[5])
    end
end

# traverse path keeping count of maximum displacement
(x, y) = (start_x, start_y)
(last_x, last_y) = (x, y)
steps = 0
while ((x,y) ≠ (start_x, start_y) || steps == 0)
    @debug x, y
    steps += 1
    (test_x, test_y) = (x + mappings[x, y][1], y + mappings[x, y][2])
    if (test_x, test_y) == (last_x, last_y)
        (test_x, test_y) = (x + mappings[x, y][3], y + mappings[x, y][4])
    end
    (last_x, last_y) = (x, y)
    (x, y) = (test_x, test_y)
end
println("Total steps in loop = " * string(steps))
println("So maximum displacement = " * string(ceil(Int64,steps/2)))
