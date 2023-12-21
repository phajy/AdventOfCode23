using Logging
using Crayons
using Plots
using DelimitedFiles
global_logger(ConsoleLogger(stderr, Logging.Debug))

day = "18"
# filename = "test"
filename = "input"

problem = readdlm("2023-12-" * day * "/" * day * "-" * filename * ".txt", ' ')

dict = Dict("R" => (1, 0), "L" => (-1, 0), "U" => (0, 1), "D" => (0, -1))

x = 0
y = 0
trench_x = [x]
trench_y = [y]
area = 0.0
circumference = 0.0
for index in range(1, size(problem, 1))
    (Δx, Δy) = dict[problem[index, 1]]
    Δx = Δx * problem[index, 2]
    Δy = Δy * problem[index, 2]
    circumference += abs(Δx) + abs(Δy)
    # "shoelace" formula (https://en.wikipedia.org/wiki/Shoelace_formula)
    area += 0.5 * (2 * y + Δy) * (-Δx)
    x += Δx
    y += Δy
    push!(trench_x, x)
    push!(trench_y, y)
end
@debug "x, y = ", x, y
area += 0.5 * (y) * (x)

plot(trench_x, trench_y)

println("Area: ", area)
println("Circumference: ", circumference)
println("Requied area = ", abs(area) + circumference / 2 + 1)
