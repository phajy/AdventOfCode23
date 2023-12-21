using Logging
using Crayons

# set debug level
global_logger(ConsoleLogger(stderr, Logging.Error))

day = "21"
# filename = "test"
filename = "input"

# read problem file
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

function show_problem(parsed_problem, positions)
    dict = Dict(
        '.' => Crayon(foreground=:blue),
        '#' => Crayon(foreground=:red),
        'S' => Crayon(foreground=:green),
        'O' => Crayon(foreground=:yellow),
        'g' => Crayon(foreground=:green),
    )
    n_rows = size(parsed_problem)[1]
    n_columns = size(parsed_problem)[2]
    print("\u1b[H")
    print(dict['g'], "╔")
    for column in range(1, n_columns + 2)
        print("═")
    end
    println("╗")
    for row in range(1, n_rows)
        print("║ ")
        for column in range(1, n_columns)
            if (row, column) in positions
                print(dict['O'], 'O')
            else
                print(dict[parsed_problem[row, column]], parsed_problem[row, column])
            end
        end
        println(dict['g'], " ║")
    end
    print("╚")
    for column in range(1, n_columns + 2)
        print("═")
    end
    println("╝")
end

problem = parse_problem("2023-12-" * day * "/" * day * "-" * filename * ".txt")

# find starting position
indices = findfirst(isequal('S'), problem)
row = indices[1]
column = indices[2]

# figure out possible next steps
function next_step(current_positions)
    global problem
    new_positions = []
    # @debug "exploring ", row, ", ", column, " after ", steps_taken, " steps"
    for position in current_positions
        for step in [(1, 0), (-1, 0), (0, 1), (0, -1)]
            new_row = position[1] + step[1]
            new_column = position[2] + step[2]
            if checkbounds(Bool, problem, new_row, new_column)
                if problem[new_row, new_column] == '.' ||
                   problem[new_row, new_column] == 'S'
                    if (new_row, new_column) ∉ new_positions
                        push!(new_positions, (new_row, new_column))
                    end
                end
            end
        end
    end
    return new_positions
end

print("\033c")

positions = [(row, column)]
for steps in range(1, 64)
    positions = next_step(positions)
    # show_problem(problem, positions)
end
show_problem(problem, positions)

n_visited = length(positions)
println("Number of squares visited = ", n_visited)
