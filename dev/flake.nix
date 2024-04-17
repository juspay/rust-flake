{
  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixpkgs-unstable";
    flake-parts.url = "github:hercules-ci/flake-parts";
    flake-root.url = "github:srid/flake-root";
    treefmt-nix.url = "github:numtide/treefmt-nix";
    git-hooks = {
      url = "github:cachix/git-hooks.nix";
      inputs.nixpkgs.follows = "nixpkgs";
      inputs.nixpkgs-stable.follows = "nixpkgs";
    };
    just-flake.url = "github:juspay/just-flake";
    rust-flake.url = "github:juspay/rust-flake";
  };

  outputs = inputs@{ self, nixpkgs, flake-parts, ... }:
    flake-parts.lib.mkFlake { inherit inputs; } {
      systems = nixpkgs.lib.systems.flakeExposed;
      imports = [
        inputs.flake-root.flakeModule
        inputs.treefmt-nix.flakeModule
        inputs.git-hooks.flakeModule
        inputs.just-flake.flakeModule
      ];
      perSystem = { pkgs, lib, config, ... }: {
        pre-commit = {
          check.enable = true;
          settings = {
            hooks = {
              treefmt.enable = true;
              convco.enable = true;
            };
          };
        };
        treefmt.config = {
          projectRoot = inputs.rust-flake;
          projectRootFile = "flake.nix";
          flakeCheck = false; # pre-commit-hooks.nix checks this
          programs.nixpkgs-fmt.enable = true;
        };
        just-flake.features = {
          treefmt.enable = true;
          convco.enable = true;
        };
        devShells.default = pkgs.mkShell {
          # cf. https://community.flake.parts/haskell-flake#composing-devshells
          inputsFrom = [
            config.just-flake.outputs.devShell
            config.treefmt.build.devShell
            config.pre-commit.devShell
          ];
          packages = [
            config.pre-commit.settings.tools.convco
          ];
        };
      };
    };
}
