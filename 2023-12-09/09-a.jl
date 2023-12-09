using DelimitedFiles
using Logging

debug_logger = ConsoleLogger(stderr, Logging.Error)
global_logger(debug_logger)

# filename = "2023-12-09/09-test.txt"
filename = "2023-12-09/09-input.txt"

histories = readdlm(filename, ' ', Int)

function next_in_history(line)
    @debug line
    lines = [line]
    level = 1
    done = false
    while !done
        next_line = []
        for i in range(1, length(lines[level]) - 1)
            Δ = lines[level][i+1] - lines[level][i]
            push!(next_line, Δ)
        end
        push!(lines, next_line)
        @debug next_line
        level += 1
        if sum(abs.(next_line)) == 0
            done = true
        end
    end
    # now do the reconstruction
    for i in range(length(lines) - 1, 1, step=-1)
        push!(lines[i], lines[i][end] + lines[i+1][end])
        @debug lines[i][end]
    end
    return lines[1][end]
end

sum_histories = 0
for row in 1:size(histories, 1)
    line = histories[row, :]
    @debug "line is ", line
    sum_histories += next_in_history(line)
end
println("Sum of histories = " * string(sum_histories))
