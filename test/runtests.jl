using Pkg
Pkg.activate(".")
import SuperconductingCircuits as SCC
using Test
import QuantumToolbox as qt
import UnicodePlots as up
using YAXArrays
@testset "SuperconductingCircuits.jl" begin
    # Write your tests here.
    include("StartupTesting/StartupTesting.jl")
end
