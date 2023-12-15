using Logging
global_logger(ConsoleLogger(stderr, Logging.Debug))

filename = "2023-12-13/13-test.txt"
# filename = "2023-12-13/13-input.txt"

function process_block(block)
    @debug "block => ", block, length(block), length(block[1])
    # scan through block for vertical symmetry
    for x in range(2, length(block[1]) - 1)
        ok = true
        for y in range(1, length(block))
            left = block[y][1:x]
            right = block[y][x+1:end]
            n = minimum([length(left), length(right)])
            # @debug n, left, right
            left = left[end+1-n:end]
            right = reverse(right[1:n])
            # @debug x, y, " compare L ", left, " widht R ", right
            if left ≠ right
                ok = false
            end
        end
        if ok
            @debug "line of symmetry between " * string(x) * " and " * string(x + 1)
        end
    end
end

ash_and_rocks = readlines(filename)
block_start = 1
for i in range(1, length(ash_and_rocks))
    if ash_and_rocks[i] == "" || i == length(ash_and_rocks)
        process_block(ash_and_rocks[block_start:i-1])
        block_start = i + 1
    end
end
