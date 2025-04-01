function tostr(obj)
    io = IOBuffer()
    show(io, "text/plain", obj)
    String(take!(io))
end

function parse_and_eval(expr, x)
    exprtoeval =  Meta.parse(expr)
    @eval eval_func(x) = $exprtoeval
    invokelatest() do 
        return eval_func(x)
    end    
end