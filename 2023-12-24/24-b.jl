# Day 24

using JuMP
using Gurobi
using Printf
using Logging
global_logger(ConsoleLogger(stderr, Logging.Debug))

day = "24"
filename = "input"

problem = readlines("2023-12-" * day * "/" * day * "-" * filename * ".txt")

r_v = []
for row in problem
    push!(r_v, parse.(Int64, split(row, r"(, | @ )")))
end

model = Model(Gurobi.Optimizer)
set_attribute(model, "SolutionLimit", 1)

@variable(model, 100000000000000 <= x <= 500000000000000, Int)
@variable(model, 100000000000000 <= y <= 500000000000000, Int)
@variable(model, 100000000000000 <= z <= 500000000000000, Int)
@variable(model, -1000 <= v_x <= 1000, Int)
@variable(model, -1000 <= v_y <= 1000, Int)
@variable(model, -1000 <= v_z <= 1000, Int)
@variable(model, λ[1:length(r_v)] >= 0)

for a in range(1, length(r_v))
    @constraint(model, x + λ[a] * (v_x - r_v[a][4]) - r_v[a][1] == 0)
    @constraint(model, y + λ[a] * (v_y - r_v[a][5]) - r_v[a][2] == 0)
    @constraint(model, z + λ[a] * (v_z - r_v[a][6]) - r_v[a][3] == 0)
end

@objective(model, Min, x + y + z)
optimize!(model)
@printf("Solution is %i ", value(x) + value(y) + value(z))
