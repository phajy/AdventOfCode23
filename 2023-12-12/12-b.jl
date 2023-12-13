using DelimitedFiles
using ProgressMeter
using Logging
global_logger(ConsoleLogger(stderr, Logging.Info))

# filename = "2023-12-12/12-test.txt"
filename = "2023-12-12/12-input.txt"

spring_records = readdlm(filename, ' ', String)

total = 0
n = size(spring_records)[1]
p = Progress(n; dt=0.5, barglyphs=BarGlyphs("[=> ]"), barlen=50, color=:yellow)
for index in range(1, size(spring_records)[1])
    next!(p)
    spring_records[index, 1] = repeat(spring_records[index, 1] * "?", 5)
    spring_records[index, 1] = spring_records[index, 1][1:end-1]
    spring_records[index, 2] = repeat(spring_records[index, 2] * ",", 5)
    spring_records[index, 2] = spring_records[index, 2][1:end-1]
    @debug spring_records[index, 1]
    @debug spring_records[index, 2]
    springs = spring_records[index, 1]
    unknowns = Int[]
    for i in range(1, length(springs))
        if springs[i] == '?'
            push!(unknowns, i)
        end
    end
    contiguous_blocks = split(spring_records[index, 2], ',')
    @debug springs
    @debug contiguous_blocks
    @info "unknowns = " * string(length(unknowns))
    # go through all possibilities and check for consistency

    trials = [spring_records[index, 1]]
    checked = [1]
    for i in range(1, length(unknowns))
        @info "Checking ", i, " of ", length(unknowns), " unknowns"
        # create two possible attempts based on the previous attempts
        new_trials = []
        new_checked = []
        for j in range(1, length(trials))
            if unknowns[i] > 1
                start = trials[j][1:unknowns[i]-1]
            else
                start = ""
            end
            if unknowns[i] < length(trials[j])
                finish = trials[j][unknowns[i]+1:end]
            else
                finish = ""
            end
            push!(new_trials, start * "." * finish)
            push!(new_checked, checked[j])
            push!(new_trials, start * "#" * finish)
            push!(new_checked, checked[j])
        end
        # @debug "new trials = ", new_trials
        trials = []
        checked = []
        for j in range(1,length(new_trials))
            # clean up trial to parse
            # @debug new_trials[j]
            clean_trial = replace(new_trials[j], r"\.\.+" => ".")
            clean_trial = replace(clean_trial, r"^\.+" => "")
            clean_trial = replace(clean_trial, r"\.+$" => "")
            blocks = split(clean_trial, '.')
            # @debug "row = ", index, " trial = ", clean_trial, " blocks = ", blocks
            ok = true
            if match(r"\?", clean_trial) == nothing
                if length(blocks) != length(contiguous_blocks)
                    ok = false
                    # @debug "  no remaining ? but lengths don't match"
                    # @debug clean_trial
                end
            end
            # @debug "into k loop"
            checked_range = 1
            for k in range(new_checked[j], min(length(blocks), length(contiguous_blocks)))
                if match(r"\?", blocks[k]) == nothing
                    if length(blocks[k]) != parse(Int, contiguous_blocks[k])
                        ok = false
                        # @debug "ruled out ", new_trials[j]
                        break
                    end
                else
                    break
                end
                checked_range = k
            end
            # @debug "out of k loop"
            if ok
                push!(trials, new_trials[j])
                push!(checked, checked_range)
                # @debug "keeping ", new_trials[j]
            end
        end
    end
    @debug "number remaining = ", length(trials)
    @info "Found ", length(trials)
    total += length(trials)
    # @debug trials
end
println("Total = ", total)
