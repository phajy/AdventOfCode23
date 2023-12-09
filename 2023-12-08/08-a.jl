using Logging
debug_logger = ConsoleLogger(stderr, Logging.Error)
global_logger(debug_logger)

# filename = "2023-12-08/08-test.txt"
filename = "2023-12-08/08-input.txt"

lines = readlines(filename)

# first line contains out instructions
instructions = lines[1]

# the rest of the file contains the mappings
# make a dictionary
dict = Dict()
for (index, line) in enumerate(lines[3:end])
    dict[line[1:3]] = index
end

# create the mappings
lr = []
for (index, line) in enumerate(lines[3:end])
    push!(lr, (dict[line[8:10]], dict[line[13:15]]))
end

# follow the instructions
pos = dict["AAA"]
index = 1
steps = 0
while pos != dict["ZZZ"]
    @debug "Current position = ", lines[pos+2][1:3]
    instructions[index] == 'L' ? pos = lr[pos][1] : pos = lr[pos][2]
    steps += 1
    index += 1
    if index > length(instructions)
        index = 1
    end
end

println("Number of steps = ", steps)
