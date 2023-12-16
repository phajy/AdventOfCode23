using Logging
# debug_logger = ConsoleLogger(stderr, Logging.Debug)
# global_logger(debug_logger)

filename = "2023-12-01/01-a-input.txt"
lines = readlines(filename)
running_total = 0
text_numbers = ["one", "two", "three", "four", "five", "six", "seven", "eight", "nine"]
for line in lines
    for (index, text_number) in enumerate(text_numbers)
        # some characters can be part of more than one number (e.g., "nineighthreeight")
        line = replace(line, text_number => text_number * string(index) * text_number)
    end
    first_digit = parse(Int, match(r"\d", line).match)
    last_digit = parse(Int, match(r"\d", reverse(line)).match)
    running_total = running_total + 10 * first_digit + last_digit
end
println(running_total)
