{
  description = "A `flake-parts` module for Rust development";
  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";
    rust-overlay.url = "github:oxalica/rust-overlay";
    # https://github.com/ipetkov/crane/issues/527
    crane.url = "github:ipetkov/crane/2c653e4478476a52c6aa3ac0495e4dea7449ea0e"; # Cargo.toml parsing is broken in newer crane (Mar 24)
    crane.inputs.nixpkgs.follows = "nixpkgs";
  };
  outputs = { rust-overlay, crane, ... }: {
    flakeModules.default = import ./flake-module.nix { inherit rust-overlay crane; };
  };
}
