"""
    tostr(obj) -> String

Converts the given object `obj` to its plain text string representation by using the `show` function with the `"text/plain"` MIME type.

# Arguments
- `obj`: Any Julia object to be converted to a string.

# Returns
- `String`: The plain text representation of `obj`.
"""
function tostr(obj)
    io = IOBuffer()
    show(io, "text/plain", obj)
    String(take!(io))
end

"""
    parse_and_eval(expr::AbstractString, x)

Parses the string `expr` as a Julia expression, defines a function `eval_func(x)` that evaluates this expression with the given argument `x`, and then invokes this function using `invokelatest`.

# Arguments
- `expr::AbstractString`: A string representing a Julia expression, which should be valid code involving the variable `x`.
- `x`: The value to substitute for `x` in the evaluated expression.

# Returns
- The result of evaluating the parsed expression with the provided value of `x`.
"""
function parse_and_eval(expr, x)
    exprtoeval =  Meta.parse(expr)
    @eval eval_func(x) = $exprtoeval
    invokelatest() do 
        return eval_func(x)
    end    
end