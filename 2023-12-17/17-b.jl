# Day 17
# Updated strategy. Add another label to each node indicating the direction that the path is pointing.
# (1, 2, 3, 4) => (N, E, S, W)
# this way we can ensure that the path does not continue in the same direction or double back on itself

using JuMP
using Gurobi
using UnicodePlots
using Logging

# set debug level
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

# read, charactarize, and plot the problem
# filename = "2023-12-17/17-test.txt"
filename = "2023-12-17/17-input.txt"
heat_map = parse_problem(filename)
n_points = length(heat_map)
n_rows = size(heat_map)[1]
n_columns = size(heat_map)[2]
heatmap(heat_map)

# start a new model
model = Model(Gurobi.Optimizer)
x = Dict{NTuple{6,Int},VariableRef}()

# set up the model
# variable   : x_ijklmn is 1 if we go from (i,j) direction k to (l,m) direction n
# constraint : number of routes into every cell must equal number of routes out, except for the start and end which need to have one out and one in, respectively
# constraint : eliminate straight routes through any point
# objective  : minimize the sum of the costs along the route

# calculate the costs of moving from one node to the next
# this is not symmetric - the cost is incurred when entering a cell
# simultaneously build up a list of constraints
flow_in = Dict()
flow_out = Dict()
costs = Dict()
# costs = zeros(n_points, n_points)
for column in range(1, n_columns)
    for row in range(1, n_rows)
        for direction in range(1, 4)
            Δrow = 0
            Δcolumn = 0
            if direction == 1
                new_directions = [2, 4]
                Δrow = -1
            end
            if direction == 2
                new_directions = [1, 3]
                Δcolumn = 1
            end
            if direction == 3
                new_directions = [2, 4]
                Δrow = 1
            end
            if direction == 4
                new_directions = [1, 3]
                Δcolumn = -1
            end
            for new_direction in new_directions
                for Δ in range(4, 10)
                    new_row = row + Δ * Δrow
                    new_column = column + Δ * Δcolumn
                    if checkbounds(Bool, heat_map, new_row, new_column)
                        row_range = sort([row, new_row])
                        col_range = sort([column, new_column])
                        # cost is only occured when *entering* a cell
                        # this might get redefined multiple times but I think that's OK
                        costs[(
                            row,
                            column,
                            direction,
                            new_row,
                            new_column,
                            new_direction,
                        )] =
                            sum(
                                heat_map[
                                    row_range[1]:row_range[2],
                                    col_range[1]:col_range[2],
                                ],
                            ) - heat_map[row, column]
                        # define a variable for this path
                        x[row, column, direction, new_row, new_column, new_direction] =
                            @variable(
                                model,
                                base_name = "x[$row,$column,$direction,$new_row,$new_column,$new_direction]",
                                binary = true
                            )
                        # in and out constraints
                        if !haskey(flow_out, (row, column, direction))
                            flow_out[(row, column, direction)] = [(
                                row,
                                column,
                                direction,
                                new_row,
                                new_column,
                                new_direction,
                            )]
                        else
                            current_out = flow_out[(row, column, direction)]
                            flow_out[(row, column, direction)] = push!(
                                current_out,
                                (
                                    row,
                                    column,
                                    direction,
                                    new_row,
                                    new_column,
                                    new_direction,
                                ),
                            )
                        end
                        if !haskey(flow_in, (new_row, new_column, new_direction))
                            flow_in[(new_row, new_column, new_direction)] = [(
                                row,
                                column,
                                direction,
                                new_row,
                                new_column,
                                new_direction,
                            )]
                        else
                            current_in = flow_in[(new_row, new_column, new_direction)]
                            flow_in[(new_row, new_column, new_direction)] = push!(
                                current_in,
                                (
                                    row,
                                    column,
                                    direction,
                                    new_row,
                                    new_column,
                                    new_direction,
                                ),
                            )
                        end
                    end
                end
            end
        end
    end
end

@constraint(
    model,
    sum(x[i, j, k, l, m, n] for (i, j, k, l, m, n) in flow_out[1, 1, 2]) +
    sum(x[i, j, k, l, m, n] for (i, j, k, l, m, n) in flow_out[1, 1, 3]) == 1
)
@constraint(
    model,
    sum(x[i, j, k, l, m, n] for (i, j, k, l, m, n) in flow_in[1, 1, 1]) +
    sum(x[i, j, k, l, m, n] for (i, j, k, l, m, n) in flow_in[1, 1, 4]) == 0
)
@constraint(
    model,
    sum(x[i, j, k, l, m, n] for (i, j, k, l, m, n) in flow_out[n_rows, n_columns, 1]) +
    sum(x[i, j, k, l, m, n] for (i, j, k, l, m, n) in flow_out[n_rows, n_columns, 4]) == 0
)
@constraint(
    model,
    sum(x[i, j, k, l, m, n] for (i, j, k, l, m, n) in flow_in[n_rows, n_columns, 2]) +
    sum(x[i, j, k, l, m, n] for (i, j, k, l, m, n) in flow_in[n_rows, n_columns, 3]) == 1
)

for column in range(1, n_columns)
    for row in range(1, n_rows)
        # skip in and out points
        if !((row == 1 && column == 1) || (row == n_rows && column == n_columns))
            for direction in range(1, 4)
                if haskey(flow_in, (row, column, direction)) &&
                   haskey(flow_out, (row, column, direction))
                    @constraint(
                        model,
                        sum(
                            x[i, j, k, l, m, n] for
                            (i, j, k, l, m, n) in flow_in[row, column, direction]
                        ) == sum(
                            x[i, j, k, l, m, n] for
                            (i, j, k, l, m, n) in flow_out[row, column, direction]
                        )
                    )
                    @constraint(
                        model,
                        sum(
                            x[i, j, k, l, m, n] for
                            (i, j, k, l, m, n) in flow_in[row, column, direction]
                        ) + sum(
                            x[i, j, k, l, m, n] for
                            (i, j, k, l, m, n) in flow_out[row, column, direction]
                        ) <= 2
                    )
                else
                    if !haskey(flow_in, (row, column, direction)) &&
                       haskey(flow_out, (row, column, direction))
                        @constraint(
                            model,
                            sum(
                                x[i, j, k, l, m, n] for
                                (i, j, k, l, m, n) in flow_out[row, column, direction]
                            ) == 0
                        )
                    end
                    if !haskey(flow_out, (row, column, direction)) &&
                       haskey(flow_in, (row, column, direction))
                        @constraint(
                            model,
                            sum(
                                x[i, j, k, l, m, n] for
                                (i, j, k, l, m, n) in flow_in[row, column, direction]
                            ) == 0
                        )
                    end
                end
            end
        end
    end
end

@objective(
    model,
    Min,
    sum(
        costs[i, j, k, l, m, n] * x[i, j, k, l, m, n] for (i, j, k, l, m, n) in keys(costs)
    )
)

optimize!(model)

x_coords = Int64[]
y_coords = Int64[]
for edge in x
    if value(edge[2]) > 0.5
        @debug edge
        push!(x_coords, edge[1][2])
        push!(x_coords, edge[1][5])
        push!(y_coords, edge[1][1])
        push!(y_coords, edge[1][4])
    end
end
scatterplot(
    x_coords,
    y_coords,
    canvas = DotCanvas,
    xlim = (1, n_columns),
    ylim = (1, n_rows),
    border = :ascii,
)

solution_summary(model)
