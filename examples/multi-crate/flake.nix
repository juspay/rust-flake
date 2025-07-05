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
      perSystem = { self', ... }: {
        devShells.default = self'.devShells.rust;

        # nix run . -- 10 + 5
        packages.default = self'.packages.calculator;
      };
    };
}
