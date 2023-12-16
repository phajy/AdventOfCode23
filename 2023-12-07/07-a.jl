using CSV, DataFrames
using Logging
debug_logger = ConsoleLogger(stderr, Logging.Error)
global_logger(debug_logger)

# filename = "2023-12-07/07-test.txt"
filename = "2023-12-07/07-input.txt"

hands = CSV.read(filename, DataFrame, header = false, delim = ' ', ignorerepeated = true)

function hand_type(cards)
    cards_array = sort(collect(cards))
    unique_cards = []
    n_cards = []
    for card in cards_array
        if card in unique_cards
            n_cards[end] += 1
        else
            push!(unique_cards, card)
            push!(n_cards, 1)
        end
    end
    n_cards = sort(n_cards, rev = true)
    if n_cards[1] == 5
        @debug "Five of a kind (7)"
        return 7
    end
    if n_cards[1] == 4
        @debug "Four of a kind (6)"
        return 6
    end
    if n_cards[1] == 3 && n_cards[2] == 2
        @debug "Full house (5)"
        return 5
    end
    if n_cards[1] == 3
        @debug "Three of a kind (4)"
        return 4
    end
    if n_cards[1] == 2 && n_cards[2] == 2
        @debug "Two pairs (3)"
        return 3
    end
    if n_cards[1] == 2
        @debug "One pair (2)"
        return 2
    end
    @debug "High card (1)"
    return 1
end

# return true if hand_1 is less than hand_2
function compare_hands(hand_1, hand_2)
    hand_1_type = hand_type(hand_1)
    hand_2_type = hand_type(hand_2)
    if hand_1_type > hand_2_type
        return false
    end
    if hand_1_type < hand_2_type
        return true
    end
    # hands are of the same type
    # compare card by card in order
    dict = Dict(
        'A' => 14,
        'K' => 13,
        'Q' => 12,
        'J' => 11,
        'T' => 10,
        '9' => 9,
        '8' => 8,
        '7' => 7,
        '6' => 6,
        '5' => 5,
        '4' => 4,
        '3' => 3,
        '2' => 2,
    )
    for i in range(1, 5)
        card_1 = dict[hand_1[i]]
        card_2 = dict[hand_2[i]]
        if card_1 > card_2
            return false
        end
        if card_1 < card_2
            return true
        end
    end
    # hands are equal
    return false
end

n_rows = size(hands, 1)

sorted_hands = sort(hands, lt = (x, y) -> compare_hands(x, y))

total = 0
for row = 1:n_rows
    total += row * sorted_hands[row, 2]
end

println("Total: ", total)
