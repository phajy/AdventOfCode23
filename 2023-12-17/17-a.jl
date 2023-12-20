# Day 17

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
x = Dict{NTuple{4,Int},VariableRef}()

# set up the model
# variable   : x_ij is 1 if we go from i to j, 0 if not
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
        for Δ in [1, 2, 3]
            for Δsign in [-1, 1]
                for Δrow in [true, false]
                    new_row = row + Δ * Δsign * Δrow
                    new_column = column + Δ * Δsign * !Δrow
                    if checkbounds(Bool, heat_map, new_row, new_column)
                        row_range = sort([row, new_row])
                        col_range = sort([column, new_column])
                        # cost is only occured when *entering* a cell
                        costs[(row, column, new_row, new_column)] = sum(heat_map[row_range[1]:row_range[2], col_range[1]:col_range[2]]) - heat_map[row, column]
                        # define a variable for this path
                        x[row, column, new_row, new_column] = @variable(model, base_name = "x[$row,$column,$new_row,$new_column]", binary = true)
                        # in and out constraints
                        if !haskey(flow_out, (row, column))
                            flow_out[(row, column)] = [(new_row, new_column)]
                        else
                            current_out = flow_out[(row, column)]
                            flow_out[(row, column)] = push!(current_out, (new_row, new_column))
                        end
                        if !haskey(flow_in, (new_row, new_column))
                            flow_in[(new_row, new_column)] = [(row, column)]
                        else
                            current_in = flow_in[(new_row, new_column)]
                            flow_in[(new_row, new_column)] = push!(current_in, (row, column))
                        end
                    end
                end
            end
        end
    end
end

@constraint(model, sum(x[1, 1, k, l] for (k, l) in flow_out[1, 1]) == 1)
@constraint(model, sum(x[i, j, 1, 1] for (i, j) in flow_in[1, 1]) == 0)
@constraint(model, sum(x[n_rows, n_columns, k, l] for (k, l) in flow_out[n_rows, n_columns]) == 0)
@constraint(model, sum(x[i, j, n_rows, n_columns] for (i, j) in flow_in[n_rows, n_columns]) == 1)

for column in range(1, n_columns)
    for row in range(1, n_rows)
        # skip in and out points
        if !((row == 1 && column == 1) || (row == n_rows && column == n_columns))
            @debug "adding constraint", row, column
            @constraint(model, sum(x[i, j, row, column] for (i, j) in flow_in[row, column]) == sum(x[row, column, k, l] for (k, l) in flow_out[row, column]))
        end
    end
end

# get rid of all double straight paths
# ah, also need to get rid of double-backs (didn't realise until I saw this in a solution)
for row in range(1, n_rows)
    for column in range(1, n_columns)
        for Δ_1 in [1, 2, 3]
            for Δ_2 in [1, 2, 3]
                for Δsign in [-1, 1]
                    for Δrow in [true, false]
                        # straight through
                        new_row_1 = row + Δ_1 * Δsign * Δrow
                        new_column_1 = column + Δ_1 * Δsign * !Δrow
                        new_row_2 = row - Δ_2 * Δsign * Δrow
                        new_column_2 = column - Δ_2 * Δsign * !Δrow
                        if checkbounds(Bool, heat_map, new_row_1, new_column_1) && checkbounds(Bool, heat_map, new_row_2, new_column_2)
                            # @debug "trying to ban the move ", new_row_2, ", ", new_column_2, " => ", row, ", ", column, " => ", new_row_1, ", ", new_column_1
                            @constraint(model, x[new_row_2, new_column_2, row, column] + x[row, column, new_row_1, new_column_1] <= 1)
                        end
                        # double-back
                        new_row_1 = row + Δ_1 * Δsign * Δrow
                        new_column_1 = column + Δ_1 * Δsign * !Δrow
                        new_row_2 = row + Δ_2 * Δsign * Δrow
                        new_column_2 = column + Δ_2 * Δsign * !Δrow
                        if checkbounds(Bool, heat_map, new_row_1, new_column_1) && checkbounds(Bool, heat_map, new_row_2, new_column_2)
                            # @debug "trying to ban the move ", new_row_2, ", ", new_column_2, " => ", row, ", ", column, " => ", new_row_1, ", ", new_column_1
                            @constraint(model, x[new_row_2, new_column_2, row, column] + x[row, column, new_row_1, new_column_1] <= 1)
                        end
                    end
                end
            end
        end
    end
end

@objective(model, Min, sum(costs[i, j, k, l] * x[i, j, k, l] for (i, j, k, l) in keys(costs)))
optimize!(model)

x_coords = Int64[]
y_coords = Int64[]
for edge in x
    if value(edge[2]) > 0.5
        push!(x_coords, edge[1][2])
        push!(x_coords, edge[1][4])
        push!(y_coords, edge[1][1])
        push!(y_coords, edge[1][3])
    end
end
scatterplot(x_coords, y_coords, canvas=DotCanvas, xlim=(1, n_columns), ylim=(1, n_rows), border=:ascii)

solution_summary(model)
