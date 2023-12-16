using DelimitedFiles
using LRUCache
using Memoization
using Logging
global_logger(ConsoleLogger(stderr, Logging.Error))

# it is clear that this needs to be done "properly" as brute force is just too hard!

# filename = "2023-12-12/12-test.txt"
filename = "2023-12-12/12-input.txt"

"""
    Count the number of possible configurations of the given a map fragment showing the layout of springs that are compatible with the required pattern of springs
"""

# need to get memoization working properly!
@memoize LRU{Tuple{Any,Any},Any}(maxsize = 1024) function n_configs(
    map_fragment,
    spring_groups,
)
    # if we have run out of groups there must be no more springs
    # @debug map_fragment, spring_groups
    if spring_groups == []
        if '#' ∉ map_fragment
            return 1
        else
            return 0
        end
    end

    # if there are more groups but no map_fragment it won't work
    if map_fragment == ""
        return 0
    end

    function hash()
        # if we've found a # this can only work if the first n characters of the fragment have the same length as the spring group length and are then followed by a dot or the end of the string
        # @debug map_fragment, spring_groups
        if spring_groups[1] > length(map_fragment)
            # map fragment isn't long enough
            return 0
        end
        start_of_fragment = map_fragment[1:spring_groups[1]]
        start_of_fragment = replace(start_of_fragment, "?" => "#")
        # if we can't fit all the springs it can't be done
        if start_of_fragment ≠ "#"^spring_groups[1]
            return 0
        end
        # if this finishes off the map fragment and this is the last group we're done
        if length(map_fragment) == spring_groups[1]
            if length(spring_groups) == 1
                return 1
            end
            # if there are more groups we can't do it
            return 0
        end
        # check that next character can be a break; skip that break
        if map_fragment[spring_groups[1]+1] ∈ ".?"
            # @debug map_fragment, " and ", spring_groups, " => ", map_fragment[spring_groups[1]+1:end], " and ", spring_groups[2:end]
            return n_configs(map_fragment[spring_groups[1]+2:end], spring_groups[2:end])
        end
        # otherwise can't be done
        return 0
    end

    function dot()
        # just skip over the dot
        return n_configs(map_fragment[2:end], spring_groups)
    end

    output = 0
    if map_fragment[1] == '#'
        output = hash()
    end
    if map_fragment[1] == '.'
        output = dot()
    end
    if map_fragment[1] == '?'
        output = hash() + dot()
    end

    # @debug map_fragment, spring_groups, "=> ", output
    return output
end

spring_records = readdlm(filename, ' ', String)

total = 0
for index in range(1, size(spring_records)[1])
    spring_records[index, 1] = repeat(spring_records[index, 1] * "?", 5)
    spring_records[index, 1] = spring_records[index, 1][1:end-1]
    spring_records[index, 2] = repeat(spring_records[index, 2] * ",", 5)
    spring_records[index, 2] = spring_records[index, 2][1:end-1]

    springs = split(spring_records[index, 2], ',')
    spring_groups = Int64[]
    for i in range(1, length(springs))
        push!(spring_groups, parse(Int, springs[i]))
    end

    n = n_configs(spring_records[index, 1], spring_groups)
    total += n
    println(spring_records[index, 1] * " => ", string(n))
end

println("Grant total = ", total)
