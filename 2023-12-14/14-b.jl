using Logging
using Crayons
global_logger(ConsoleLogger(stderr, Logging.Debug))

# got to day 14 and I think I need a general routine that I can re-use
# our convention for accessing 2D arrays is [row, column]
# the frist row will be the first row of the file
function parse_problem(filename)
    problem = readlines(filename)
    n_rows = length(problem)
    n_columns = length(problem[1])
    parsed_problem = Array{Char}(undef, n_rows, n_columns)
    for row in range(1, n_rows)
        for column in range(1, n_columns)
            parsed_problem[row, column] = problem[row][column]
        end
    end
    return parsed_problem
end

function show_problem(parsed_problem)
    g_fg = Crayon(foreground=:green)
    r_fg = Crayon(foreground=:red)
    b_fg = Crayon(foreground=:blue)
    gr_fg = Crayon(foreground=:light_gray)
    n_rows = size(parsed_problem)[1]
    n_columns = size(parsed_problem)[2]
    print("\u1b[H")
    print(g_fg, "╔")
    for column in range(1, n_columns + 2)
        print("═")
    end
    println("╗")
    for row in range(1, n_rows)
        print("║ ")
        for column in range(1, n_columns)
            if parsed_problem[row, column] == '#'
                print(r_fg)
            end
            if parsed_problem[row, column] == 'O'
                print(b_fg)
            end
            if parsed_problem[row, column] == '.'
                print(gr_fg)
            end
            print(parsed_problem[row, column], g_fg)
        end
        println(" ║")
    end
    print("╚")
    for column in range(1, n_columns + 2)
        print("═")
    end
    println("╝")
end

function move_rocks(rock_map, direction)
    moved = 0
    load = 0
    updated_rock_map = deepcopy(rock_map)
    n_rows = size(rock_map)[1]
    n_columns = size(rock_map)[2]
    for row in range(1, n_rows)
        for column in range(1, n_columns)
            # if we find a rock see if we can move it
            if rock_map[row, column] == 'O'
                load += n_rows - row + 1
                move_to_row = row + direction[1]
                move_to_column = column + direction[2]
                if move_to_row >= 1 &&
                   move_to_row <= n_rows &&
                   move_to_column >= 1 &&
                   move_to_column <= n_columns
                    if rock_map[move_to_row, move_to_column] == '.'
                        updated_rock_map[row, column] = '.'
                        updated_rock_map[move_to_row, move_to_column] = 'O'
                        load -= direction[1]
                        moved += 1
                    end
                end
            end
        end
    end
    return (updated_rock_map, load, moved)
end

# filename = "2023-12-14/14-test.txt"
filename = "2023-12-14/14-input.txt"

rock_map = parse_problem(filename)

print("\033c")

previous_maps = []
load = 0
index = 1
finishing = false
while index <= 1_000_000_000
    # keep a cache of every state visited to identify cycles
    start_map = deepcopy(rock_map)
    if start_map ∈ previous_maps && finishing == false
        println(index, " => this has previously been mapped at ", findfirst(x -> x == start_map, previous_maps))
        Δ = index - findfirst(x -> x == start_map, previous_maps)
        println("Δ = ", Δ)
        # we can jump forward by integer multiples of Δ
        index += Δ * (div(1_000_000_000 - index, Δ) - 1)
        println("jumped to ", index)
        finishing = true
    end
    push!(previous_maps, deepcopy(rock_map))
    # do one cycle
    for dir in [(-1, 0), (0, -1), (1, 0), (0, 1)]
        moved = 1
        while (moved != 0)
            (rock_map, load, moved) = move_rocks(rock_map, dir)
        end
    end
    println(index, " => ", load)
    index += 1
end
show_problem(rock_map)
println("Load = ", load)
