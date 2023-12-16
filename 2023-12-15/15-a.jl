using Crayons
using DelimitedFiles
using Logging
global_logger(ConsoleLogger(stderr, Logging.Error))

# filename = "2023-12-15/15-test.txt"
filename = "2023-12-15/15-input.txt"

function calc_hash(inst_hash, step)
    for i in range(1, length(step))
        inst_hash += Int(step[i])
        inst_hash = inst_hash * 17
        inst_hash = mod(inst_hash, 256)
    end
    return inst_hash
end

instructions = readdlm(filename, ',')
inst_hash = 0
for step in instructions
    inst_hash += calc_hash(0, step)
    @debug "Hash so far = ", inst_hash
end
println("Instruction hash = ", inst_hash)
