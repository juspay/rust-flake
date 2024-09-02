{
  description = "A `flake-parts` module for Rust development";
  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";
    rust-overlay.url = "github:oxalica/rust-overlay";
    rust-overlay.flake = false;
    crane.url = "github:ipetkov/crane";
    crane.inputs.nixpkgs.follows = "nixpkgs";
  };
  outputs = { rust-overlay, crane, ... }: {
    flakeModules = {
      default = import ./nix/modules/flake-module.nix { inherit rust-overlay crane; };
      nixpkgs = import ./nix/modules/nixpkgs.nix;
    };
    nixci.default =
      let
        overrideInputs = {
          rust-flake = ./.;
        };
      in
      {
        dev = { inherit overrideInputs; dir = "dev"; };
      };
  };
}
