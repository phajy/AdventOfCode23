# Day 23

using JuMP
using Gurobi
using Logging

# set debug level
global_logger(ConsoleLogger(stderr, Logging.Error))

day = "23"
# filename = "test"
filename = "input"

function parse_problem(filename)
    problem = readlines(filename)
    n_rows = length(problem)
    n_columns = length(problem[1])
    parsed_problem = fill(' ', n_rows, n_columns)
    for row in range(1, n_rows)
        for column in range(1, n_columns)
            parsed_problem[row, column] = problem[row][column]
        end
    end
    return parsed_problem
end

map = parse_problem("2023-12-" * day * "/" * day * "-" * filename * ".txt")

n_rows = size(map)[1]
n_columns = size(map)[2]

# start a new model
model = Model(Gurobi.Optimizer)
x = Dict{NTuple{4,Int},VariableRef}()

# set up the model
# variable   : x_ijkl is 1 if we go from (i,j) to (k,l). This will be sparse and not symmetric because of the hills.
# constraint : number of routes into every cell must equal number of routes out, except for the start and end which need to have one out and one in, respectively
# constraint : eliminate straight routes through any point
# objective  : minimize the sum of the costs along the route

# calculate the costs of moving from one node to the next
# this is not symmetric - the cost is incurred when entering a cell
# simultaneously build up a list of constraints
flow_in = Dict()
flow_out = Dict()
costs = Dict()
correct_way = Dict('>' => (0, 1), '<' => (0, -1), '^' => (-1, 0), 'v' => (1, 0))
start_column = 0
end_column = 0
# costs = zeros(n_points, n_points)
for column in range(1, n_columns)
    for row in range(1, n_rows)
        if row == 1 && map[row, column] == '.'
            start_column = column
        end
        if row == n_rows && map[row, column] == '.'
            end_column = column
        end
        for (Δrow, Δcolumn) in [(0, 1), (0, -1), (1, 0), (-1, 0)]
            new_row = row + Δrow
            new_column = column + Δcolumn
            # go through a series of checks to see if this is a valid move
            # is this a map cell we can move through?
            ok = (map[row, column] ≠ '#')
            # are we tring to move to a cell on the map?
            ok = (ok && checkbounds(Bool, map, new_row, new_column))
            # are we going downhill?
            if ok && map[row, column] ∈ ['>', '<', '^', 'v']
                ok = ((Δrow, Δcolumn) == correct_way[map[row, column]])
            end
            # are moving to a valid space?
            if ok
                ok = (map[new_row, new_column] != '#')
            end
            if ok
                # cost for a step is just 1
                costs[(row, column, new_row, new_column)] = 1
                # definte a variable for this step
                x[(row, column, new_row, new_column)] = @variable(
                    model,
                    base_name = "x[$row,$column,$new_row,$new_column]",
                    binary = true
                )
                # maintain a list of all out and in paths so we can limit them to one each
                # outflow
                if !haskey(flow_out, (row, column))
                    flow_out[(row, column)] = [(row, column, new_row, new_column)]
                else
                    current_out = flow_out[(row, column)]
                    flow_out[(row, column)] =
                        push!(current_out, (row, column, new_row, new_column))
                end
                # inflow
                if !haskey(flow_in, (new_row, new_column))
                    flow_in[(new_row, new_column)] = [(row, column, new_row, new_column)]
                else
                    current_in = flow_in[(new_row, new_column)]
                    flow_in[(new_row, new_column)] =
                        push!(current_in, (row, column, new_row, new_column))
                end
            end
        end
    end
end

# start point outflow constraint
@constraint(model, sum(x[i, j, k, l] for (i, j, k, l) in flow_out[1, start_column]) == 1)
# start point inflow constraint
@constraint(model, sum(x[i, j, k, l] for (i, j, k, l) in flow_in[1, start_column]) == 0)
# end point outflow constraint
@constraint(model, sum(x[i, j, k, l] for (i, j, k, l) in flow_out[n_rows, end_column]) == 0)
# end poitn inflow constraint
@constraint(model, sum(x[i, j, k, l] for (i, j, k, l) in flow_in[n_rows, end_column]) == 1)

for column in range(1, n_columns)
    # exclude first and last rows because they were handled separately above
    for row in range(2, n_rows - 1)
        # number of paths in = number of paths out; maximum one path in and one path out
        # can't double back
        if haskey(flow_in, (row, column)) && haskey(flow_out, (row, column))
            @constraint(
                model,
                sum(x[i, j, k, l] for (i, j, k, l) in flow_in[row, column]) ==
                sum(x[i, j, k, l] for (i, j, k, l) in flow_out[row, column])
            )
            @constraint(
                model,
                sum(x[i, j, k, l] for (i, j, k, l) in flow_in[row, column]) +
                sum(x[i, j, k, l] for (i, j, k, l) in flow_out[row, column]) <= 2
            )
            for check_each_out in flow_out[row, column]
                flow_to_row = check_each_out[3]
                flow_to_column = check_each_out[4]
                if haskey(x, (flow_to_row, flow_to_column, row, column))
                    @constraint(
                        model,
                        x[row, column, flow_to_row, flow_to_column] +
                        x[flow_to_row, flow_to_column, row, column] <= 1
                    )
                end
            end
        end
    end
end


@objective(
    model,
    Max,
    sum(costs[i, j, k, l] * x[i, j, k, l] for (i, j, k, l) in keys(costs))
)

optimize!(model)

solution_summary(model)

map_solution = deepcopy(map)
for edge in x
    if value(edge[2]) > 0.5
        @debug edge
        Δrow = edge[1][3] - edge[1][1]
        Δcolumn = edge[1][4] - edge[1][2]
        if Δrow == 0 && Δcolumn == 1
            map_solution[edge[1][1], edge[1][2]] = '>'
        end
        if Δrow == 0 && Δcolumn == -1
            map_solution[edge[1][1], edge[1][2]] = '<'
        end
        if Δrow == 1 && Δcolumn == 0
            map_solution[edge[1][1], edge[1][2]] = 'v'
        end
        if Δrow == -1 && Δcolumn == 0
            map_solution[edge[1][1], edge[1][2]] = '^'
        end
        # map_solution[edge[1][1], edge[1][2]] = 'O'
    end
end
map_solution[n_rows, end_column] = 'O'
for row in range(1, n_rows)
    for column in range(1, n_columns)
        print(map_solution[row, column])
    end
    println()
end
