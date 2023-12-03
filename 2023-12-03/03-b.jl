using Logging
debug_logger = ConsoleLogger(stderr, Logging.Error)
global_logger(debug_logger)

# filename = "2023-12-03/03-a-test.txt"
filename = "2023-12-03/03-a-input.txt"
lines = readlines(filename)
running_total = 0
for (y, line) in enumerate(lines)
    # find gears
    gears = eachmatch(r"[\*]", line)
    for gear in gears
        @debug "  gear at ", gear.offset, y, " in line ", line
        x = gear.offset
        # find surrounding numbers and store their starting coordinates
        found_numbers = []
        product = 1
        for cx in range(x-1, x+1)
            for cy in range(y-1, y+1)
                if checkbounds(Bool, lines, cy)
                    if checkbounds(Bool, lines[cy], cx)
                        if match(r"\d", string(lines[cy][cx])) != nothing
                            # we've found a digit; now find the number
                            numbers = eachmatch(r"\d+", lines[cy])
                            for number in numbers
                                # see if this overlaps with the desired digig
                                if number.offset <= cx <= number.offset + length(number.match) - 1
                                    coords_and_val = (number.offset, cy, parse(Int, number.match))
                                    if coords_and_val ∉ found_numbers
                                        push!(found_numbers, coords_and_val)
                                        @debug "adding " * number.match * " to list"
                                        @debug found_numbers
                                        product = product * parse(Int, number.match)
                                    end
                                end
                            end
                        end
                    end
                end
            end
        end
        @debug "found ", length(found_numbers), " numbers with product ", product
        if length(found_numbers) == 2
            running_total += product
        end
    end
end
println("Total = ", running_total)
