using SuperconductingCircuits
using Documenter
using DocumenterVitepress

DocMeta.setdocmeta!(SuperconductingCircuits, :DocTestSetup, :(using SuperconductingCircuits); recursive=true)

const PAGES = [
    "Home" => "index.md",
    "Getting Started" => [
        "Overview" => "getting_started/overview.md",
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
        repo = "",
    ),
    pages = PAGES,
    checkdocs = :none
)

DocumenterVitepress.deploydocs(;
    repo = "",
    target = "build", # this is where Vitepress stores its output
    devbranch = "main",
    branch = "main",
    push_preview = true,
)

# using SuperconductingCircuits
# using Documenter

# DocMeta.setdocmeta!(SuperconductingCircuits, :DocTestSetup, :(using SuperconductingCircuits); recursive=true)

# makedocs(;
#     modules = [SuperconductingCircuits],
#     repo = "",#Remotes.GitHub("ExampleOrg", "Example.jl"),
#     authors = "Gavin Rockwood",
#     sitename = "SuperconductingCircuits.jl",
#     format = Documenter.HTML(;
#         canonical = "https://github.com/ExampleOrg/Example.jl",
#         edit_link = "main",
#         assets = String[],
# ),
#     pages = [
#         "Home" => "index.md",
#     ],
#     checkdocs = :none,
# )

# deploydocs(;
#     repo = "",
#     devbranch = "main",
# )