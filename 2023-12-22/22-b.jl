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
while done == false
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

# ok, new we need to see how many blocks fall when we remove them one at a time
total_falling = 0
for check_block in range(1, length(blocks))
    # @debug "Removing block ", check_block
    new_blocks = deepcopy(blocks)
    # disintegrate check_block
    deleteat!(new_blocks, check_block)

    # duplicate code from above
    falling = []
    done = false
    while done == false
        done = true
        for i in range(1, length(new_blocks))
            # @debug " seeing if block ", i, " can fall"
            piece = deepcopy(new_blocks[i])
            piece[3] -= 1
            piece[6] -= 1
            if piece[3] > 0 && piece[6] > 0
                intersections = test_for_intersection(piece, new_blocks, i)
                if length(intersections) == 0
                    new_blocks[i] = piece
                    done = false
                    # @debug " ... new_block index ", i, " is falling"
                    if i ∉ falling
                        push!(falling, i)
                    end
                    # break
                end
            end
        end
    end
    @debug "The number of blocks falling as a result of deleting block ",
    check_block,
    " is ",
    length(falling)
    total_falling += length(falling)
end

println("Total falling blocks = ", total_falling)
