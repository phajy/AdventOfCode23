using CSV, DataFrames
using Logging
debug_logger = ConsoleLogger(stderr, Logging.Error)
global_logger(debug_logger)

# filename = "2023-12-06/06-test.txt"
filename = "2023-12-06/06-input.txt"

times_and_distances = CSV.read(filename, DataFrame, header=false, delim=' ', ignorerepeated=true)

num_races = ncol(times_and_distances)-1
@debug "There are " * string(num_races) * " races"

running_total = 1
for race in range(1, num_races)
    total_time = times_and_distances[1, race+1]
    target_distance = times_and_distances[2, race+1]
    n_wins = 0
    for t_hold in range(1, total_time)
        speed = t_hold
        distance = speed * (total_time - t_hold)
        if distance > target_distance
            n_wins += 1
        end
    end
    @debug string(n_wins) * " ways to win"
    running_total *= n_wins
end
println(running_total)
