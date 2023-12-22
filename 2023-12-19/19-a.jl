using Logging
using Plots
using DelimitedFiles
global_logger(ConsoleLogger(stderr, Logging.Error))

day = "19"
# filename = "test"
filename = "input"

problem = readlines("2023-12-" * day * "/" * day * "-" * filename * ".txt")

dict = Dict()
total = 0
# ensure variable are declared in an appropriate scope
x = m = a = s = 0
for line in problem
    # see if we have an insturction or a starting point
    if match(r"^{", line) == nothing
        # we have an instruction
        instructions = split(line, r"[{},]")
        # @debug "splits to ", instructions
        dict[instructions[1]] = instructions[2:end-1]
    else
        # we have a starting point
        # @debug "starting point ", line
        starting_point = split(line, r"[{},=]")
        # @debug "splits to ", starting_point
        x = parse(Int, starting_point[3])
        m = parse(Int, starting_point[5])
        a = parse(Int, starting_point[7])
        s = parse(Int, starting_point[9])
        @debug "starting point ", x, m, a, s
        step = "in"
        # follow instructions
        done = false
        while !done
            @debug "step ", step
            instructions = dict[step]
            for i in range(1, length(instructions))
                if i == length(instructions)
                    # got to end of instructin list so do what is asked
                    # accept
                    if instructions[i] == "A"
                        total += x + m + a + s
                        @debug "adding ", x + m + a + s, " to total"
                        done = true
                    end
                    # reject
                    if instructions[i] == "R"
                        done = true
                    end
                    # go to next step
                    step = instructions[i]
                else
                    # check condition to see if it is satisfied
                    condition = split(instructions[i], ":")
                    @debug condition
                    @debug "xmas = ", x, m, a, s
                    if eval(Meta.parse(condition[1]))
                        # expression satisfied
                        step = condition[2]
                        if step == "A"
                            total += x + m + a + s
                            @debug "adding ", x + m + a + s, " to total"
                            done = true
                        end
                        if step == "R"
                            done = true
                        end
                        break
                    end
                end
            end
        end
    end
end
println("total = ", total)
