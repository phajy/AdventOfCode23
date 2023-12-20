# I'm just including this for completeness
# It should have been immediatley obvious that a brute force approach with minimal pruning was going to fail miserably!

using Logging
using Crayons
using UnicodePlots
global_logger(ConsoleLogger(stderr, Logging.Error))

# read problem file
# the frist row will be the first row of the file
function parse_problem(filename)
    problem = readlines(filename)
    n_rows = length(problem)
    n_columns = length(problem[1])
    parsed_problem = Array{Int64}(undef, n_rows, n_columns)
    for row in range(1, n_rows)
        for column in range(1, n_columns)
            parsed_problem[row, column] = parse(Int64, string(problem[row][column]))
        end
    end
    return parsed_problem
end

function traverse_map!(
    length,
    route_map,
    best_so_far,
    current_cost,
    heat_map,
    row,
    column,
    Δrow,
    Δcolumn,
)
    @debug length, row, column, current_cost, Δrow, Δcolumn
    n_rows = size(heat_map)[1]
    n_columns = size(heat_map)[2]
    # see if we're done or off the map
    if row < 1 || row > n_rows || column < 1 || column > n_columns
        @debug "off map"
        return best_so_far
    end

    if Δcolumn == 1
        route_char = '>'
    end
    if Δcolumn == -1
        route_char = '<'
    end
    if Δrow == 1
        route_char = 'v'
    end
    if Δrow == -1
        route_char = '^'
    end
    if route_map[row, column] == route_char
        @debug "we've done this before - we're in a loop"
        return best_so_far
    end
    route_map[row, column] = route_char

    # show_problem(route_map, heat_map, row, column)
    # sleep(0.25)

    if (row == n_rows) && (column == n_columns)
        @debug "found end with cost ", current_cost, " compared with ", best_so_far
        if current_cost < best_so_far
            best_so_far = current_cost
            @debug "new best: ", best_so_far
            sleep(5)
        end
        return (best_so_far)
    end
    # try moving one, two, or three spaces
    # add the cost when moving
    for multiple ∈ [1, 2, 3]
        new_row = row + multiple * Δrow
        new_column = column + multiple * Δcolumn
        # @debug "trying ", new_row, new_column
        if new_row < 1 || new_row > n_rows || new_column < 1 || new_column > n_columns
            # not a valid move
        else
            # try all possible directions that are different
            for (new_Δrow, new_Δcolumn) ∈ [(1, 0), (-1, 0), (0, 1), (0, -1)]
                # @debug "from ", Δrow, Δcolumn, " trying direction ", new_Δrow, new_Δcolumn
                # sleep(1)
                # make sure direction has changed
                if !(new_Δrow == Δrow && new_Δcolumn == Δcolumn)
                    # make sure we've not turned 180 degrees
                    if !(new_Δrow == -Δrow && new_Δcolumn == -Δcolumn)
                        new_cost =
                            current_cost + sum(heat_map[row:new_row, column:new_column])
                        if new_cost < best_so_far
                            best_so_far = traverse_map!(
                                length+1,
                                route_map,
                                best_so_far,
                                new_cost,
                                heat_map,
                                new_row,
                                new_column,
                                new_Δrow,
                                new_Δcolumn,
                            )
                        end
                    end
                end
            end
        end
    end
    return best_so_far
end

filename = "2023-12-17/17-test.txt"
# filename = "2023-12-17/17-input.txt"

heat_map = parse_problem(filename)

heatmap(heat_map)

best_so_far = 1_000_000_000
route_map = fill('.', size(heat_map))
best_so_far = traverse_map!(0,route_map, best_so_far, -heat_map[1, 1], heat_map, 1, 1, 1, 0)
route_map = fill('.', size(heat_map))
best_so_far = traverse_map!(0,route_map, best_so_far, -heat_map[1, 1], heat_map, 1, 1, 0, 1)
