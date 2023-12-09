using CSV, DataFrames
using Logging
debug_logger = ConsoleLogger(stderr, Logging.Error)
global_logger(debug_logger)

# filename = "2023-12-07/07-test.txt"
filename = "2023-12-07/07-input.txt"

hands = CSV.read(filename, DataFrame, header=false, delim=' ', ignorerepeated=true)

# update to consider jokers
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
    # I think that if there is more than one joker they should always represent the same rank card to get the strongest final hand
    # This card should be the most represented card in the hand
    n_jokers = 0
    if 'J' ∈ unique_cards
        joker_index = findfirst(isequal('J'), unique_cards)
        n_jokers = n_cards[joker_index]
        deleteat!(unique_cards, joker_index)
        deleteat!(n_cards, joker_index)
    end
    @debug "n_jokers: ", n_jokers

    if n_jokers == 5
        return 7
    end

    n_cards = sort(n_cards, rev=true)
    # add jokers where they help the most
    n_cards[1] += n_jokers
    strongest = 0
    if n_cards[1] == 5
        @debug "Five of a kind (7)"
        strongest = 7
    end
    if n_cards[1] == 4
        if 6 > strongest
            @debug "Four of a kind (6)"
            strongest = 6
        end
    end
    if n_cards[1] == 3 && n_cards[2] == 2
        if 5 > strongest
            @debug "Full house (5)"
            strongest = 5
        end
    end
    if n_cards[1] == 3
        if 4 > strongest
            @debug "Three of a kind (4)"
            strongest = 4
        end
    end 
    if n_cards[1] == 2 && n_cards[2] == 2
        if 3 > strongest
            @debug "Two pairs (3)"
            strongest = 3
        end
    end
    if n_cards[1] == 2
        if 2 > strongest
            @debug "One pair (2)"
            strongest = 2
        end
    end
    if 1 > strongest
        @debug "High card (1)"
        strongest = 1
    end
    return strongest
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
    # note that now J = joker is the least valuable
    dict = Dict('A'=>14, 'K'=>13, 'Q'=>12, 'T'=>10, '9'=>9, '8'=>8, '7'=>7, '6'=>6, '5'=>5, '4'=>4, '3'=>3, '2'=>2, 'J'=>1)
    for i in range(1,5)
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

sorted_hands = sort(hands, lt=(x,y)->compare_hands(x, y))

total = 0
for row in 1:n_rows
    total += row * sorted_hands[row, 2]
end

println("Total: ", total)