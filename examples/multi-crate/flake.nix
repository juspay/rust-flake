{
  description = "Single crate example for rust-flake";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixpkgs-unstable";
    flake-parts.url = "github:hercules-ci/flake-parts";
    rust-flake.url = "path:../../."; # TODO: replace with url once <https://github.com/juspay/rust-flake/pull/40>
  };

  outputs = inputs:
    inputs.flake-parts.lib.mkFlake { inherit inputs; } {
      systems = [ "x86_64-linux" "aarch64-linux" "x86_64-darwin" "aarch64-darwin" ];
      debug = true;
      imports = [
        inputs.rust-flake.flakeModules.default
        inputs.rust-flake.flakeModules.nixpkgs
      ];

      perSystem = { self', config, ... }: {
        rust-project = {
          crateNixFile = "crate.nix";
        };

        devShells.default = self'.devShells.rust;
        packages.default = config.rust-project.crates.crate-a.crane.outputs.drv.crate;
      };
    };
}
