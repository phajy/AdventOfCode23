using Logging
using Crayons
using Plots
using DelimitedFiles
global_logger(ConsoleLogger(stderr, Logging.Debug))

day = "18"
# filename = "test"
filename = "input"

problem = readdlm("2023-12-" * day * "/" * day * "-" * filename * ".txt", ' ')

dict = Dict('0' => (1, 0), '2' => (-1, 0), '3' => (0, 1), '1' => (0, -1))

x = 0
y = 0
trench_x = [x]
trench_y = [y]
area = 0.0
circumference = 0.0
for index in range(1, size(problem, 1))
    direction = problem[index, 3][8]
    distance = parse(Int64, problem[index, 3][3:7], base=16)
    (Δx, Δy) = dict[direction]
    Δx = Δx * distance
    Δy = Δy * distance
    circumference += abs(Δx) + abs(Δy)
    # "shoelace" formula (https://en.wikipedia.org/wiki/Shoelace_formula)
    area += 0.5 * (2 * y + Δy) * (-Δx)
    x += Δx
    y += Δy
    push!(trench_x, x)
    push!(trench_y, y)
end
area += 0.5 * (y) * (x)

plot(trench_x, trench_y)

println("Area: ", area)
println("Circumference: ", circumference)
println("Requied area = ", abs(area) + circumference / 2 + 1)
