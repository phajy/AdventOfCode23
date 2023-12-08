using Logging
debug_logger = ConsoleLogger(stderr, Logging.Error)
global_logger(debug_logger)

# filename = "2023-12-05/05-test.txt"
filename = "2023-12-05/05-input.txt"
lines = readlines(filename)

# seed ranges listed as from_1, to_1, from_2, to_2, ...
seed_ranges = []
map_from_to = []

for line in lines
    # see if we have a list of seeds or a map
    if match(r":", line) != nothing
        # list of seeds?
        if match(r"^seeds", line) != nothing
            seeds = parse.(Int64, split(line, " ")[2:end])
            for index in range(start=1, stop=length(seeds), step=2)
                push!(seed_ranges, (seeds[index], seeds[index] + seeds[index+1]))
            end
            seed_ranges = sort(seed_ranges, lt=(x,y)->isless(x[1], y[1]))
        end
        # a new map?
        if match(r"map:", line) != nothing
            # reset mapping
            map_from_to = []
        end
    elseif !isempty(line)
        # we have a map (not a blank line)
        numbers = parse.(Int64, split(line, " "))
        push!(map_from_to, (numbers[2], numbers[2] + numbers[3], numbers[1], numbers[1] + numbers[3]))
    elseif length(map_from_to) > 0
        # blank line means we can proceed with the mapping
        # make sure there is a blank line at the end of the file
        # step through the map and iterate until no more remapping needs to be done
        remapped_seeds = []
        for map in map_from_to
            done = false
            while !done
                done = true
                for (index, seed_range) in enumerate(seed_ranges)
                    # see if range is a perfect subset of map range
                    if seed_range[1] >= map[1] && seed_range[2] <= map[2]
                        push!(remapped_seeds, (seed_range[1] - map[1] + map[3], seed_range[2] - map[1] + map[3]))
                        deleteat!(seed_ranges, index)
                        done = false
                        break
                    end
                    # see if there is any overlap with start of map range
                    if seed_range[1] < map[1] && seed_range[2] >= map[1]
                        seed_ranges[index] = (seed_range[1], map[1] - 1)
                        push!(seed_ranges, (map[1], seed_range[2]))
                        done = false
                        break
                    end
                    # see if there is any overlap with end of map range
                    if seed_range[2] <= map[2] && seed_range[2] > map[2]
                        seed_ranges[index] = (seed_range[1], map[2])
                        push!(seed_ranges, (map[2] + 1, seed_range[2]))
                        done = false
                        break
                    end
                end
            end
        end
        # add unmapped seeds
        seed_ranges = vcat(seed_ranges, remapped_seeds)
    end
end

seed_ranges = sort(seed_ranges, lt=(x,y)->isless(x[1], y[1]))
println("Closest location = ", seed_ranges[1][1])
