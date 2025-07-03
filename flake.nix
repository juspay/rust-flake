{
  description = "A `flake-parts` module for Rust development";
  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";
    rust-overlay.url = "github:oxalica/rust-overlay";
    rust-overlay.inputs.nixpkgs.follows = "nixpkgs";
    crane.url = "github:ipetkov/crane";
    globset = {
      url = "github:pdtpartners/globset";
      inputs.nixpkgs-lib.follows = "nixpkgs";
    };
  };
  outputs = { rust-overlay, crane, globset, ... }:
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
        default = import' ./nix/modules/flake-module.nix { inherit rust-overlay crane globset; };
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
