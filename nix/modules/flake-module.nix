inputs:
{ self, pkgs, lib, flake-parts-lib, ... }:

let
  inherit (flake-parts-lib)
    mkPerSystemOption;
in
{
  options = {
    perSystem = mkPerSystemOption
      ({ config, self', pkgs, system, ... }: {
        imports = [
          ./default-crates.nix
          ./devshell.nix
        ];
        options = {
          # TODO: Multiple projects
          rust-project = {
            crates = lib.mkOption {
              description = ''Attrset of crates pointing to the local path, which has its Cargo.toml file'';
              type = lib.types.attrsOf (lib.types.submoduleWith {
                modules = [ ./crate.nix ];
                specialArgs = {
                  inherit (config) rust-project;
                  inherit pkgs;
                };
              });
            };

            crane-lib = lib.mkOption {
              type = lib.types.lazyAttrsOf lib.types.raw;
              default = (inputs.crane.mkLib pkgs).overrideToolchain config.rust-project.toolchain;
            };
            toolchain = lib.mkOption {
              type = lib.types.package;
              description = "Rust toolchain to use for the rust-project package";
              default = (pkgs.rust-bin.fromRustupToolchainFile (self + /rust-toolchain.toml)).override {
                extensions = [
                  "rust-src"
                  "rust-analyzer"
                  "clippy"
                ];
              };
            };

            src = lib.mkOption {
              type = lib.types.path;
              description = "Source directory for the rust-project package";
              default = lib.cleanSourceWith {
                src = self; # The original, unfiltered source
                filter = path: type:
                  # Default filter from crane (allow .rs files)
                  (config.rust-project.crane-lib.filterCargoSources path type)
                ;
              };
            };

            cargoToml = lib.mkOption {
              type = lib.types.attrsOf lib.types.raw;
              description = ''
                Cargo.toml parsed in Nix
              '';
              default = builtins.fromTOML (builtins.readFile (self + /Cargo.toml));
            };
          };
        };
        config = {
          # See nix/modules/nixpkgs.nix (the user must import it)
          nixpkgs.overlays = [
            inputs.rust-overlay.overlays.default
          ];

          # lib.mapAttrs over config.rust-project.crates returning its outputs.packages (combined)
          packages =
            lib.mkMerge
              (lib.mapAttrsToList
                (name: crate: crate.crane.outputs.packages)
                config.rust-project.crates);

          checks = lib.mkMerge
            (lib.mapAttrsToList
              (name: crate: crate.crane.outputs.checks)
              config.rust-project.crates);
        };
      });
  };
}
