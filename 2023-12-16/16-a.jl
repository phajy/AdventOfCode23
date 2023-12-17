using Logging
using Crayons
global_logger(ConsoleLogger(stderr, Logging.Error))

# got to day 14 and I think I need a general routine that I can re-use
# our convention for accessing 2D arrays is [row, column]
# the frist row will be the first row of the file
function parse_problem(filename)
    problem = readlines(filename)
    n_rows = length(problem)
    n_columns = length(problem[1])
    parsed_problem = Array{Char}(undef, n_rows, n_columns)
    for row in range(1, n_rows)
        for column in range(1, n_columns)
            parsed_problem[row, column] = problem[row][column]
        end
    end
    return parsed_problem
end

function show_problem(beam_map, parsed_problem, cur_row, cur_column)
    g_fg = Crayon(foreground = :green)
    r_fg = Crayon(foreground = :red)
    b_fg = Crayon(foreground = :blue)
    y_fg = Crayon(foreground = :yellow)
    n_rows = size(parsed_problem)[1]
    n_columns = size(parsed_problem)[2]
    print("\u1b[H")
    print(g_fg, "╔")
    for column in range(1, n_columns + 2)
        print("═")
    end
    println("╗")
    for row in range(1, n_rows)
        print("║ ", b_fg)
        for column in range(1, n_columns)
            if parsed_problem[row, column] ∈ ['|', '\\', '/', '-']
                print(r_fg)
            end
            if beam_map[row, column] != '.'
                print(y_fg)
            end
            if row == cur_row && column == cur_column
                print('*', b_fg)
            else
                print(parsed_problem[row, column], b_fg)
            end
        end
        println(g_fg, " ║")
    end
    print("╚")
    for column in range(1, n_columns + 2)
        print("═")
    end
    println("╝")
end

function trace_beam!(beam_map, mirror_map, row, column, Δrow, Δcolumn)
    if row < 1 || row > size(mirror_map, 1) || column < 1 || column > size(mirror_map, 2)
        return
    end

    if Δcolumn == 1
        beam_char = '>'
    end
    if Δcolumn == -1
        beam_char = '<'
    end
    if Δrow == 1
        beam_char = 'v'
    end
    if Δrow == -1
        beam_char = '^'
    end
    if beam_map[row, column] == beam_char
        @debug "we've done this before - we're in a loop"
        return
    end
    beam_map[row, column] = beam_char

    # visualise the beam - only practical for the test case
    # show_problem(beam_map, mirror_map, row, column)
    # sleep(0.5)

    # move laser beam to next square
    if mirror_map[row, column] == '.'
        new_row = row + Δrow
        new_column = column + Δcolumn
        trace_beam!(beam_map, mirror_map, new_row, new_column, Δrow, Δcolumn)
    end
    # reflect laser beam
    if mirror_map[row, column] ∈ ['/', '\\']
        # (a)  ^
        #    > /

        #  (b) / <
        #      v

        # (c)  v
        #     </

        # (d)  />
        #      ^

        # (e) >\
        #      v

        # (f)  ^
        #      \<

        # (g)  v
        #      \>

        # (h) >\
        #      v
        Δdir = 1
        if mirror_map[row, column] == '/'
            Δdir = -1
        end
        # @debug "row = ", row, " column = ", column, " Δrow = ", Δrow, " Δcolumn = ", Δcolumn
        new_Δrow = Δdir * Δcolumn
        new_Δcolumn = Δdir * Δrow
        new_row = row + new_Δrow
        new_column = column + new_Δcolumn
        # @debug "new row = ", new_row, " new column = ", new_column, " new Δrow = ", new_Δrow, " new Δcolumn = ", new_Δcolumn
        # error("first reflection")
        trace_beam!(beam_map, mirror_map, new_row, new_column, new_Δrow, new_Δcolumn)
    end
    # beam splitter
    if mirror_map[row, column] ∈ ['|', '-']
        if Δrow == 0 && mirror_map[row, column] == '|'
            trace_beam!(beam_map, mirror_map, row + 1, column, 1, 0)
            trace_beam!(beam_map, mirror_map, row - 1, column, -1, 0)
        end
        if Δrow == 0 && mirror_map[row, column] == '-'
            trace_beam!(beam_map, mirror_map, row, column + Δcolumn, 0, Δcolumn)
        end
        if Δcolumn == 0 && mirror_map[row, column] == '-'
            trace_beam!(beam_map, mirror_map, row, column + 1, 0, 1)
            trace_beam!(beam_map, mirror_map, row, column - 1, 0, -1)
        end
        if Δcolumn == 0 && mirror_map[row, column] == '|'
            trace_beam!(beam_map, mirror_map, row + Δrow, column, Δrow, 0)
        end
    end
end

# filename = "2023-12-16/16-test.txt"
filename = "2023-12-16/16-input.txt"

mirror_map = parse_problem(filename)
beam_map = fill('.', size(mirror_map))

print("\033c")
show_problem(beam_map, mirror_map, 0, 0)

# trace beam currently at (row, column) moving in direction (Δrow, Δcolumn)
# returns a list of all (possibly multiply) energized squares
trace_beam!(beam_map, mirror_map, 1, 1, 0, 1)

show_problem(beam_map, mirror_map, 0, 0)

n_energized = count(x -> x != '.', beam_map)
println("Number of energized squares = ", n_energized)
