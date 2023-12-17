using Crayons
using DelimitedFiles
using Logging
global_logger(ConsoleLogger(stderr, Logging.Error))

# filename = "2023-12-15/15-test.txt"
filename = "2023-12-15/15-input.txt"

function calc_hash(step)
    inst_hash = 0
    for i in range(1, length(step))
        inst_hash += Int(step[i])
        inst_hash = inst_hash * 17
        inst_hash = mod(inst_hash, 256)
    end
    return inst_hash
end

function show_status(lenses)
    focusing_power = 0
    for index in range(1, 256)
        if lenses[index] ≠ []
            print("Box ", index-1, ": ")
            for (i, lens) in enumerate(lenses[index])
                print("[", lens[1], " ", lens[2], "] ")
                focusing_power += index *  i * lens[2]
            end
            println()
        end
    end
    return(focusing_power)
end

# note that lenses has indices 1 to 256
# boxes are numbered 0 to 255
# box 0 is in index 1, etc.
lenses = [ [] for _ in 1:256 ]

instructions = readdlm(filename, ',')
for step in instructions
    @debug "Current instruction = ", step
    inst_split = split(step, r"[-=]")
    box = calc_hash(inst_split[1])
    @debug "Box = ", box
    # should we add a lens?
    if '=' ∈ step
        focal_length = parse(Int, inst_split[2])
        @debug "Focal lengh = ", focal_length
        if inst_split[1] ∈ [t[1] for t in lenses[box+1]]
            @debug "Lens ", inst_split[1], " is already in box so replace it with ", focal_length
            index = findfirst(item -> item == inst_split[1], [t[1] for t in lenses[box+1]])
            @debug "  found at index ", index
            lenses[box+1][index] = (inst_split[1], focal_length)
        else
            push!(lenses[box+1], (inst_split[1], focal_length))
        end
    end
    # should we remove a lens?
    if '-' ∈ step
        if inst_split[1] ∈ [t[1] for t in lenses[box+1]]
            @debug "Lens ", inst_split[1], " is in box so remove it"
            index = findfirst(item -> item == inst_split[1], [t[1] for t in lenses[box+1]])
            @debug "  found at index ", index
            deleteat!(lenses[box+1], index)
        end
    end
end

focusing_power = show_status(lenses)
println("Focusing power = ", focusing_power)
