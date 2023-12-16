using Logging
# debug_logger = ConsoleLogger(stderr, Logging.Debug)
# global_logger(debug_logger)

filename = "2023-12-01/01-a-input.txt"
lines = readlines(filename)
running_total = 0
for line in lines
    first_digit = parse(Int, match(r"\d", line).match)
    last_digit = parse(Int, match(r"\d", reverse(line)).match)
    running_total = running_total + 10 * first_digit + last_digit
end
println(running_total)
