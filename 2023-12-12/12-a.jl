using DelimitedFiles
using Logging
global_logger(ConsoleLogger(stderr, Logging.Error))

# filename = "2023-12-12/12-test.txt"
filename = "2023-12-12/12-input.txt"

spring_records = readdlm(filename, ' ', String)

total_good = 0
for index in range(1, size(spring_records)[1])
    @debug spring_records[index, 1]
    @debug spring_records[index, 2]
    springs = spring_records[index, 1]
    unknowns = 0
    for i in range(1, length(springs))
        if springs[i] == '?'
            unknowns += 1
        end
    end
    contiguous_blocks = split(spring_records[index, 2], ',')

    # go through all possibilities and check for consistency
    good = 0
    for i = 1:2^unknowns
        # create new fixed spring list
        fixed_springs = ""
        k = i
        for j in range(1, length(springs))
            if springs[j] == '?'
                mod(k, 2) == 0 ? new_char = '.' : new_char = '#'
                k = div(k, 2)
            else
                new_char = springs[j]
            end
            fixed_springs = fixed_springs * new_char
        end
        @debug "trying " * fixed_springs
        # get rid of repeated, initial, and trailing dots
        fixed_springs = replace(fixed_springs, r"\.\.+" => ".")
        fixed_springs = replace(fixed_springs, r"^\.+" => "")
        fixed_springs = replace(fixed_springs, r"\.+$" => "")
        # check to see if it works
        blocks = split(fixed_springs, '.')
        ok = true
        if length(blocks) != length(contiguous_blocks)
            ok = false
        else
            for j in range(1, length(blocks))
                if length(blocks[j]) != parse(Int, contiguous_blocks[j])
                    ok = false
                end
            end
        end
        if ok
            good += 1
        end
    end
    @debug "good = " * string(good)
    total_good += good
end

println("Total good = ", total_good)
