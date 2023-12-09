using Logging

debug_logger = ConsoleLogger(stderr, Logging.Error)
global_logger(debug_logger)

# filename = "2023-12-08/08-b-test.txt"
filename = "2023-12-08/08-input.txt"

lines = readlines(filename)

# first line contains out instructions
instructions = lines[1]

# the rest of the file contains the mappings and pick out starting positions
pos = []
# make a dictionary
dict = Dict()
for (index, line) in enumerate(lines[3:end])
    dict[line[1:3]] = index
    if match(r"..A", line[1:3]) != nothing
        push!(pos, index)
    end
end
@debug pos

# create the mappings
lr = []
for (index, line) in enumerate(lines[3:end])
    push!(lr, (dict[line[8:10]], dict[line[13:15]]))
end

# follow the instructions
index = 1
steps = 1
done = falses(length(pos))
n_steps = zeros(Int, length(pos))
while false ∈ done
    for i in range(1, length(pos))
        instructions[index] == 'L' ? pos[i] = lr[pos[i]][1] : pos[i] = lr[pos[i]][2]
        if lines[pos[i]+2][3] == 'Z'
            done[i] = true
            n_steps[i] = steps
        end
    end
    steps += 1
    index += 1
    if index > length(instructions)
        index = 1
    end
end

@debug n_steps

# Calculate the LCM of elements in n_steps
lcm_n_steps = lcm(n_steps)

println("Steps required = ", lcm_n_steps)
