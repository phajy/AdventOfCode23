using Logging
global_logger(ConsoleLogger(stderr, Logging.Error))

# N.B. file has to end with new lines which indicates the end of an input block!
# each morror block now has exactly one smudge, i.e., one . => # or # => .

# filename = "2023-12-13/13-test.txt"
filename = "2023-12-13/13-input.txt"

function process_block(block)
    # @debug "block => ", block
    # scan through block for vertical symmetry
    # can transpose matrix for horizontal symmetry
    n_rows = size(block)[1]
    n_cols = size(block)[2]

    for x in range(1, n_cols - 1)
        discrepancies = 0
        for y in range(1, n_rows)
            x_off = 0
            while x_off >= 0
                l_x = x - x_off
                r_x = x + 1 + x_off
                if l_x < 1 || r_x > n_cols
                    x_off = -1
                else
                    if block[y, l_x] ≠ block[y, r_x]
                        discrepancies += 1
                    end
                    x_off += 1
                end
            end
        end
        if discrepancies == 1
            @debug "One change will produces a line of symmetry between " * string(x) * " and " * string(x + 1)
            return x
        end
    end
    return 0
end

ash_and_rocks = readlines(filename)
block_start = 1
total = 0
for i in range(1, length(ash_and_rocks))
    if ash_and_rocks[i] == ""
        # ash . => false
        # rock # => true
        # @debug block_start, i - 1, i - block_start, length(ash_and_rocks[1])
        block = falses(i - block_start, length(ash_and_rocks[block_start]))
        for y in range(block_start, i - 1)
            for x in range(1, length(ash_and_rocks[block_start]))
                if ash_and_rocks[y][x] == '#'
                    block[y+1-block_start, x] = true
                end
            end
        end
        @debug block_start
        @debug "horizontal"
        total = total + process_block(block)
        @debug "vertical"
        total = total + 100 * process_block(transpose(block))
        block_start = i + 1
    end
end

println("Total is ", total)
