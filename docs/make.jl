using Documenter, SuperconductingCircuits
using DocumenterVitepress

makedocs(; sitename="Superconducting Circuits",
            repo = " ",
            format = MarkdownVitepress(md_output_path = ".", build_vitepress = false, repo = " "),
            clean = false)