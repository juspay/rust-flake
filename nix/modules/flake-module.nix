rustFlakeInputs:
{ inputs, self, pkgs, lib, flake-parts-lib, ... }:

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
          ./defaults.nix
        ];
        options = {
          # TODO: Multiple projects
          rust-project = {
            crates = lib.mkOption {
              description = ''Attrset of crates pointing to the local path, which has its Cargo.toml file'';
              type = lib.types.attrsOf (lib.types.submoduleWith {
                modules = [ ./crate.nix ];
                specialArgs = {
                  flake = { inherit inputs; };
                  inherit (config) rust-project;
                  inherit pkgs system;
                };
              });
            };

            globset = lib.mkOption {
              default = rustFlakeInputs.globset;
            };

            crane-lib = lib.mkOption {
              type = lib.types.lazyAttrsOf lib.types.raw;
              description = ''
                The value of `crane.mkLib pkgs` providing crane library functions
              '';
              default = (rustFlakeInputs.crane.mkLib pkgs).overrideToolchain config.rust-project.toolchain;
              defaultText = lib.literalExpression "computed from `rust-flake.inputs.crane` and [`perSystem.rust-project.toolchain`](#opt-perSystem.rust-project.toolchain)";
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
              defaultText = lib.literalMD ''
                Based on the `rust-toolchain.toml` file in the flake directory
              '';
            };

            crateNixFile = lib.mkOption {
              type = lib.types.nullOr lib.types.str;
              description = ''
                The Nix file to import automatically if it exists in the
                crate directory.

                By default, nothing is automagically imported.
              '';
              default = null;
            };

            src = lib.mkOption {
              type = lib.types.path;
              description = "Source directory for the rust-project package";
              default = lib.cleanSourceWith {
                src = self; # The original, unfiltered source
                # TODO(DRY): Consolidate with that of default-crates.nix
                filter = path: type:
                  (config.rust-project.crateNixFile != null && lib.hasSuffix "/${config.rust-project.crateNixFile}" path) ||
                  # Default filter from crane (allow .rs files)
                  (config.rust-project.crane-lib.filterCargoSources path type)
                ;
              };
              defaultText = lib.literalMD ''
                Files in this flake (`self`) filtered by crane
              '';
            };

            cargoToml = lib.mkOption {
              type = lib.types.attrsOf lib.types.raw;
              description = ''
                Cargo.toml parsed in Nix
              '';
              default = builtins.fromTOML (builtins.readFile (self + /Cargo.toml));
              defaultText = lib.literalExpression ''
                fromTOML (readFile (self + "/Cargo.toml"))
              '';
            };
          };
        };
        config = {
          # See nix/modules/nixpkgs.nix (the user must import it)
          nixpkgs.overlays = [
            (import rustFlakeInputs.rust-overlay)
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
