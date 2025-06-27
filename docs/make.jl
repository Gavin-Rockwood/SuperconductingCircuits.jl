using SuperconductingCircuits
using Documenter
using DocumenterVitepress

DocMeta.setdocmeta!(SuperconductingCircuits, :DocTestSetup, :(using SuperconductingCircuits); recursive=true)
const PAGES = [
    "Home" => "index.md",
    "Getting Started" => [
        "Overview" => "getting_started/overview.md",
    ],
    "User Guide" => [
        "Circuits" => [
            "Circuit Elements" => "user_guide/circuits/circuit_elements/circuit_elements.md",
            "Building Circuits" => "user_guide/circuits/building_circuits/building_circuits.md",
        ],
        "Dynamics" => [
            "Floquet Tools" => "user_guide/dynamics/floquet/floquet.md",
        ],
    ],
    "Resources" => [
        "API" => "resources/api.md",
    ],   
]

makedocs(;
    modules = [SuperconductingCircuits],
    authors = "Gavin Rockwood",
    sitename = "SuperconductingCircuits.jl",
    format = DocumenterVitepress.MarkdownVitepress(
        repo = "github.com/Gavin-Rockwood/SuperconductingCircuits.jl",
    ),
    pages = PAGES,
    checkdocs = :none
)

DocumenterVitepress.deploydocs(;
    repo = "github.com/Gavin-Rockwood/SuperconductingCircuits.jl",
    target = joinpath(@__DIR__, "build"),
    devbranch = "main",
    branch = "gh-pages",
    push_preview = true,
)

