using Logging
global_logger(ConsoleLogger(stderr, Logging.Debug))

day = "22"
# filename = "test"
filename = "input"

# read in the problem
problem = readlines("2023-12-" * day * "/" * day * "-" * filename * ".txt")
blocks = []
max_bounds = [0, 0, 0]
for line in problem
    push!(blocks, parse.(Int, split(line, r"[,~]")))
    max_bounds = max.(max_bounds, blocks[end][1:3], blocks[end][4:6])
end

function check_overlap(a, b, c, d)
    if a <= d && c <= b
        return true
    else
        return false
    end
end

# note that none of the blocks are "diagonal"
# they all align with the coordinate axes
function test_for_intersection(piece, blocks, self_id)
    intersections = []
    for i in range(1, length(blocks))
        if check_overlap(piece[1], piece[4], blocks[i][1], blocks[i][4]) &&
           check_overlap(piece[2], piece[5], blocks[i][2], blocks[i][5]) &&
           check_overlap(piece[3], piece[6], blocks[i][3], blocks[i][6])
            if i ≠ self_id
                push!(intersections, i)
            end
        end
    end
    return intersections
end

# let all of the blocks settle
done = false
cant_remove = []
n_passes = 1
while done == false
    @debug "Pass ", n_passes, " through the blocks."
    n_passes += 1
    done = true
    cant_remove = []
    for i in range(1, length(blocks))
        piece = deepcopy(blocks[i])
        piece[3] -= 1
        piece[6] -= 1
        if piece[3] > 0 && piece[6] > 0
            intersections = test_for_intersection(piece, blocks, i)
            if length(intersections) == 0
                blocks[i] = piece
                done = false
                # break
            end
            if length(intersections) == 1
                if intersections[1] ∉ cant_remove
                    push!(cant_remove, intersections[1])
                end
            end
        end
    end
end
println("You can remove ", length(blocks) - length(cant_remove), " blocks")
