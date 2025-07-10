{
  description = "Single crate example for rust-flake";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixpkgs-unstable";
    flake-parts.url = "github:hercules-ci/flake-parts";
    rust-flake.url = "github:juspay/rust-flake";
  };

  outputs = inputs:
    inputs.flake-parts.lib.mkFlake { inherit inputs; } {
      systems = [ "x86_64-linux" "aarch64-linux" "x86_64-darwin" "aarch64-darwin" ];
      imports = [
        inputs.rust-flake.flakeModules.default
        inputs.rust-flake.flakeModules.nixpkgs
      ];

      perSystem = { self', ... }: {
        rust-project = {
          crateNixFile = "crate.nix";
          crates = {
            crate-a.path = (inputs.self) + /crates/crate-a;
          };
        };

        devShells.default = self'.devShells.rust;
        packages.default = self'.packages.crate-a;
      };
    };
}
