using Logging
debug_logger = ConsoleLogger(stderr, Logging.Error)
global_logger(debug_logger)

# filename = "2023-12-03/03-a-test.txt"
filename = "2023-12-03/03-a-input.txt"
lines = readlines(filename)
running_total = 0
for (y, line) in enumerate(lines)
    @debug line
    # find numbers in each row
    numbers = eachmatch(r"\d+", line)
    for number in numbers
        ok = false
        # check to see if number is valid
        for x in range(number.offset, number.offset + length(number.match) - 1)
            for cx in range(x-1,x+1)
                cx = max(cx, 1)
                cx = min(cx, length(line))
                for cy in range(y-1,y+1)
                    cy = max(cy, 1)
                    cy = min(cy, length(lines))
                    if match(r"[\d.]", string(lines[cy][cx])) == nothing
                        ok = true
                    end
                end
            end
        end
        if ok
            @debug number.match * " is ok"
            running_total += parse(Int, number.match)
        end
    end
end
println("Total = ", running_total)
