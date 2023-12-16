using CSV, DataFrames
using Logging
debug_logger = ConsoleLogger(stderr, Logging.Error)
global_logger(debug_logger)

# filename = "2023-12-04/04-test.txt"
filename = "2023-12-04/04-input.txt"

# n_our_numbers = 5
n_our_numbers = 10

cards = CSV.read(filename, DataFrame, header = false, delim = ' ', ignorerepeated = true)
total_cards = 0
n_rows = size(cards, 1)
n_cards = ones(Int, n_rows)
for (index, card) in enumerate(eachrow(cards))
    # count cards
    total_cards += n_cards[index]
    our_numbers = card[3:3+n_our_numbers-1]
    winning_numbers = card[3+n_our_numbers:end]
    # check our numbers
    n_matches = 0
    for number in our_numbers
        if number ∈ winning_numbers
            n_matches += 1
            if checkbounds(Bool, n_cards, index + n_matches)
                n_cards[index+n_matches] += n_cards[index]
                @debug "You've won ",
                n_cards[index],
                " extra cards at index ",
                index + n_matches
            end
        end
    end
end
println("Total cards: ", total_cards)
