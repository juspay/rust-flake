-- CI configuration <https://vira.nixos.asia/>
\ctx pipeline ->
  let isMain = ctx.branch == "main"
  in pipeline
    { build.systems =
        [ "x86_64-linux"
        , "aarch64-darwin"
        ]
    , build.flakes =
        [ "./dev" { overrideInputs = [("rust-flake", ".")] }
        , "./nix/crate-parser/test" { overrideInputs = [("crate-parser", "path:./nix/crate-parser")] }
        , "./examples/single-crate" { overrideInputs = [("rust-flake", ".")] }
        , "./examples/multi-crate" { overrideInputs = [("rust-flake", ".")] }
        ]
    , signoff.enable = True
    , cache.url = if isMain then Just "https://cache.nixos.asia/oss" else Nothing
    }
