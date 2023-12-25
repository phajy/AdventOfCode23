using Logging
global_logger(ConsoleLogger(stderr, Logging.Error))

day = "20"
# filename = "test"
filename = "input"

# Flip-flop modules (prefix %) are either on or off; they are initially off. If a flip-flop module receives a high pulse, it is ignored and nothing happens. However, if a flip-flop module receives a low pulse, it flips between on and off. If it was off, it turns on and sends a high pulse. If it was on, it turns off and sends a low pulse.
# Conjunction modules (prefix &) remember the type of the most recent pulse received from each of their connected input modules; they initially default to remembering a low pulse for each input. When a pulse is received, the conjunction module first updates its memory for that input. Then, if it remembers high pulses for all inputs, it sends a low pulse; otherwise, it sends a high pulse.
# There is a single broadcast module (named broadcaster). When it receives a pulse, it sends the same pulse to all of its destination modules.

# read in the problem
problem = readlines("2023-12-" * day * "/" * day * "-" * filename * ".txt")
dict = Dict()
for line in problem
    destinations = split(line, r"( -> |, )")
    @debug destinations
    # determine type of node
    node = ' '
    node_name = ""
    state = false
    if line[1] == '%'
        node = 'f' # flip-flop
        node_name = destinations[1][2:end]
        dict[node_name] = (node, [state], destinations[2:end])
    end
    if line[1] == '&'
        node = 'c' # conjunction
        node_name = destinations[1][2:end]
        dict[node_name] = (node, [], destinations[2:end])
    end
    if line[1] == 'b'
        node = 'b' # broadcaster
        node_name = destinations[1]
        dict[node_name] = (node, [], destinations[2:end])
    end
end

# identify which nodes are connected to the conjunction nodes
for key in keys(dict)
    node_info = dict[key]
    destinations = node_info[3]
    for destination in destinations
        # see if this is a conjunction node
        # in doing this I found that "&hf -> rx" is a conjunction node but there is no nodex "rx"
        if haskey(dict, destination)
            dest_node = dict[destination]
            if dest_node[1] == 'c'
                # add this node to the list of connected nodes and initialised with a remembered low pulse
                push!(dest_node[2], key, -1)
                # @debug "Node " * key * " connects to conjunction node " * destination
            end
        else
            @debug "Can find node " * destination
        end
    end
end

function process_pulse(pulse)
    outcome = []
    # see where the pulse is going
    if !haskey(dict, pulse[2])
        # this happens for "rx"
        @debug "Can't find node " * pulse[2]
        return outcome
    end
    pulse_to = dict[pulse[2]]
    # is this a flip-flop node?
    if pulse_to[1] == 'f'
        # this only responds to a low pulse and ignores a high pulse
        if pulse[3] == -1
            # flip state
            pulse_to[2][1] = !pulse_to[2][1]
            # send a pulse
            for send_to in pulse_to[3]
                if pulse_to[2][1] == true
                    pulse_to_send = 1
                else
                    pulse_to_send = -1
                end
                push!(outcome, (pulse[2], send_to, pulse_to_send))
            end
        end
    end
    # is this a conjunction node?
    if pulse_to[1] == 'c'
        #update memory
        all_high = true
        @debug "conjunction memory = ", pulse_to[2], " sent ", pulse[3], " from ", pulse[2]
        for i in range(1, length(pulse_to[2]) - 1)
            if pulse_to[2][i] == pulse[1]
                @debug "updating ", i
                pulse_to[2][i+1] = pulse[3]
            end
            if pulse_to[2][i+1] == -1
                all_high = false
            end
        end
        if all_high
            pulse_to_send = -1
        else
            pulse_to_send = 1
        end
        for send_to in pulse_to[3]
            push!(outcome, (pulse[2], send_to, pulse_to_send))
        end

        @debug "conjunction memory = ", pulse_to[2]

    end
    # is this the broadcast node?
    if pulse_to[1] == 'b'
        for send_to in pulse_to[3]
            push!(outcome, (pulse[2], send_to, pulse[3]))
        end
    end
    return outcome
end

n_high = 0
n_low = 0
for cycles in range(1, 1000)
    # pulses are always processed in the order sent
    # create a list of pending pulses in the format (from, to, ±1) where +1 => high, -1 => low
    # start with the main button push
    pulses = [("button", "broadcaster", -1)]
    n_low += 1
    # process first pulse in the queue and add the results to the end fo the queue
    while length(pulses) > 0
        @debug "------------new pulse-----------"
        pulse_to_process = pop!(pulses)
        @debug pulse_to_process
        new_pulses = process_pulse(pulse_to_process)
        for new_pulse in new_pulses
            pushfirst!(pulses, new_pulse)
            if (new_pulse[3] == 1)
                n_high += 1
            else
                n_low += 1
            end
        end
    end
end
println("n high = ", n_high, " n low = ", n_low)
println("product = ", n_high * n_low)
