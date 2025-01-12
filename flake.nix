{
  description = "A `flake-parts` module for Rust development";
  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";
    rust-overlay.url = "github:oxalica/rust-overlay";
    rust-overlay.flake = false;
    crane.url = "github:ipetkov/crane";
    crane.inputs.nixpkgs.follows = "nixpkgs";
  };
  outputs = { rust-overlay, crane, ... }:
    let
      # Preserve name and key of the module file for dedup and error message locations
      import' =
        modulePath: staticArg:
        {
          key = toString modulePath;
          _file = toString modulePath;
          imports = [ (import modulePath staticArg) ];
        };
    in
    {
      flakeModules = {
        default = import' ./nix/modules/flake-module.nix { inherit rust-overlay crane; };
        nixpkgs = ./nix/modules/nixpkgs.nix;
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
