using CSV, DataFrames
using Logging
debug_logger = ConsoleLogger(stderr, Logging.Error)
global_logger(debug_logger)

# filename = "2023-12-04/04-test.txt"
filename = "2023-12-04/04-input.txt"

n_our_numbers = 10

cards = CSV.read(filename, DataFrame, header=false, delim=' ', ignorerepeated=true)
total_points = 0
for card in eachrow(cards)
    our_numbers = card[3:3+n_our_numbers-1]
    winning_numbers = card[3+n_our_numbers:end]
    @debug "card = ", card
    @debug "our numbers = ", our_numbers
    @debug "winning numbers = ", winning_numbers
    # check our numbers
    points = 0
    for number in our_numbers
        if number ∈ winning_numbers
            if (points == 0)
                points = 1
            else
                points = points * 2
            end
        end
    end
    @debug card, " wins ", points
    total_points += points
end
println("Total points: ", total_points)
