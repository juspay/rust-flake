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
        ./nix/modules/rust.nix
      ];
      debug = true;
      perSystem = { self', ... }: {
        devShells.default = self'.devShells.rust;

        packages.default = self'.packages.crate-a;
      };
    };
}
