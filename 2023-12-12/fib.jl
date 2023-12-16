using Memoization

# credit to https://www.reddit.com/r/adventofcode/comments/18hbbxe/2023_day_12python_stepbystep_tutorial_with_bonus/ for a great tutorial

@memoize function fib(x)
    if x == 0
        return 0
    end
    if x == 1
        return 1
    else
        return fib(x - 1) + fib(x - 2)
    end
end

# fib(50) is too hard without memoization!

fib(500)
