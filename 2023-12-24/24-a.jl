# Day 24

using LinearSolve
using Logging
global_logger(ConsoleLogger(stderr, Logging.Error))

day = "24"
# filename = "test"
filename = "input"

problem = readlines("2023-12-" * day * "/" * day * "-" * filename * ".txt")

r_v = []
for row in problem
    push!(r_v, parse.(Int64, split(row, r"(, | @ )")))
end

xy_min = 200000000000000
xy_max = 400000000000000

function check_for_intersection(r_v_A, r_v_B, xy_min, xy_max)
    # only need to check xy for part A
    # we need to solve
    # x: x0_A + λ vx_A = x0_B + μ vx_B
    # y: y0_A + λ vy_A = y0_B + μ vy_B
    x0_A = r_v_A[1]
    y0_A = r_v_A[2]
    vx_A = r_v_A[4]
    vy_A = r_v_A[5]
    x0_B = r_v_B[1]
    y0_B = r_v_B[2]
    vx_B = r_v_B[4]
    vy_B = r_v_B[5]
    A = [Float64(vx_A) -Float64(vx_B); Float64(vy_A) -Float64(vy_B)]
    b = Float64[x0_B - x0_A, y0_B - y0_A]
    prob = LinearProblem(A, b)
    sol = solve(prob)
    if isfinite(sol.u[1]) && isfinite(sol.u[2])
        if sol.u[1] > 0 && sol.u[2] > 0
            x = x0_A + sol.u[1] * vx_A
            y = y0_A + sol.u[1] * vy_A
            if x >= xy_min && x <= xy_max && y >= xy_min && y <= xy_max
                return true
            end
        end
    end
    return false
end

# consider intersections with all other hailstonres paths in the future
n_intersections = 0
for a in range(2, length(r_v))
    for b in range(1, a-1)
        if check_for_intersection(r_v[a], r_v[b], xy_min, xy_max)
            @info "Found intersection between ", a, " and ", b
            n_intersections += 1
        end
    end
end

println("Number of intersections is ", n_intersections)
