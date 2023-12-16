using Logging
debug_logger = ConsoleLogger(stderr, Logging.Error)
global_logger(debug_logger)

# filename = "2023-12-05/05-test.txt"
filename = "2023-12-05/05-input.txt"
lines = readlines(filename)

dict = Dict()
seeds = []

cur_from = nothing
cur_to = nothing

maps = []

for line in lines
    @debug line
    # see if we have a list of seeds or a map
    if match(r":", line) != nothing
        # list of seeds?
        if match(r"^seeds", line) != nothing
            seeds = parse.(Int64, split(line, " ")[2:end])
        end
        # a new map?
        if match(r"map:", line) != nothing
            from_to = split(split(line, " ")[1], "-")
            # @debug "new map" from_to
            if !(from_to[1] in keys(dict))
                dict[from_to[1]] = length(dict) + 1
            end
            cur_from = from_to[1]
            if !(from_to[3] in keys(dict))
                dict[from_to[3]] = length(dict) + 1
            end
            cur_to = from_to[3]
        end
    elseif !isempty(line)
        # we have a map (not a blank line)
        numbers = parse.(Int64, split(line, " "))
        # @debug numbers
        push!(maps, (dict[cur_from], dict[cur_to], numbers[1], numbers[2], numbers[3]))
    end
end

# find the next step in the chain
function next_index(maps, cur_index, cur_from)
    @debug "looking for map from ", cur_index
    next_index = cur_index
    next_from = nothing
    for map in maps
        # find mappings from our current point
        if map[1] == cur_from
            next_from = map[2]
            # see if we're in the mapping range
            if map[4] <= cur_index <= map[4] + map[5]
                next_index = map[3] + cur_index - map[4]
                @debug "next index = ", next_index
            end
        end
    end
    @debug "returning next index = ", next_index, " from ", next_from
    return (next_index, next_from)
end

# now we've got the maps we need to follow each seed through the chain
lowest_end_point = 0
for seed in seeds
    @debug seed
    cur_from = dict["seed"]
    cur_index = seed
    while cur_from != dict["location"]
        @debug "stepping from ", cur_index, " from ", cur_from
        (cur_index, cur_from) = next_index(maps, cur_index, cur_from)
    end
    @debug "ended up at ", cur_index
    if cur_index < lowest_end_point || lowest_end_point == 0
        lowest_end_point = cur_index
    end
end
println("lowest end point = ", lowest_end_point)
