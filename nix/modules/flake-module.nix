inputs:
{ self, lib, flake-parts-lib, ... }:

let
  inherit (flake-parts-lib)
    mkPerSystemOption;
in
{
  options = {
    perSystem = mkPerSystemOption
      ({ config, self', pkgs, system, ... }: {
        imports = [
          {
            options.rust-project.crane.args = lib.mkOption {
              default = { };
              type = lib.types.submodule {
                freeformType = lib.types.attrsOf lib.types.raw;
              };
              description = ''
                Aguments to pass to crane's `buildPackage` and `buildDepOnly`
              '';
            };
          }
        ];
        options = {
          # TODO: Multiple projects
          rust-project.crane.args.pname = lib.mkOption {
            type = lib.types.string;
            description = "Name of the Rust crate to build";
            default = config.rust-project.cargoToml.package.name;
            defaultText = "Cargo.toml package name";
          };
          rust-project.crane.args.version = lib.mkOption {
            type = lib.types.string;
            description = "Version of the Rust crate to build";
            default = config.rust-project.cargoToml.package.version;
            defaultText = "Cargo.toml package version";
          };
          rust-project.crane.args.buildInputs = lib.mkOption {
            type = lib.types.listOf lib.types.package;
            default = [ ];
            description = "(Runtime) buildInputs for the cargo package";
          };
          rust-project.crane.args.nativeBuildInputs = lib.mkOption {
            type = lib.types.listOf lib.types.package;
            default = with pkgs; [
              pkg-config
              makeWrapper
            ];
            description = "nativeBuildInputs for the cargo package";
          };
          rust-project.crane.extraBuildArgs = lib.mkOption {
            type = lib.types.lazyAttrsOf lib.types.raw;
            default = { };
            description = "Extra arguments to pass to crane's buildPackage function";
          };
          rust-project.crane.lib = lib.mkOption {
            type = lib.types.lazyAttrsOf lib.types.raw;
            default = (inputs.crane.mkLib pkgs).overrideToolchain config.rust-project.toolchain;
          };

          rust-project.toolchain = lib.mkOption {
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

          rust-project.src = lib.mkOption {
            type = lib.types.path;
            description = "Source directory for the rust-project package";
            default = lib.cleanSourceWith {
              src = self; # The original, unfiltered source
              filter = path: type:
                # Default filter from crane (allow .rs files)
                (config.rust-project.crane.lib.filterCargoSources path type)
              ;
            };
          };

          rust-project.cargoToml = lib.mkOption {
            type = lib.types.attrsOf lib.types.raw;
            description = ''
              Cargo.toml parsed in Nix
            '';
            default = builtins.fromTOML (builtins.readFile (self + /Cargo.toml));
          };
        };
        config =
          let
            inherit (config.rust-project) toolchain crane src cargoToml;

            # Crane builder
            craneBuild = rec {
              args = crane.args // {
                inherit src;
                # glib-sys fails to build on linux without this
                # cf. https://github.com/ipetkov/crane/issues/411#issuecomment-1747533532
                strictDeps = true;
              };
              cargoArtifacts = crane.lib.buildDepsOnly args;
              buildArgs = args // {
                inherit cargoArtifacts;
              } // crane.extraBuildArgs;
              package = crane.lib.buildPackage buildArgs;

              check = crane.lib.cargoClippy (args // {
                inherit cargoArtifacts;
                cargoClippyExtraArgs = "--all-targets --all-features -- --deny warnings";
              });

              doc = crane.lib.cargoDoc (args // {
                inherit cargoArtifacts;
              });
            };

            rustDevShell = pkgs.mkShell {
              shellHook = ''
                # For rust-analyzer 'hover' tooltips to work.
                export RUST_SRC_PATH="${toolchain}/lib/rustlib/src/rust/library";
              '';
              buildInputs = [
                pkgs.libiconv
              ] ++ config.rust-project.crane.args.buildInputs;
              packages = [
                toolchain
              ] ++ config.rust-project.crane.args.nativeBuildInputs;
            };
          in
          {
            # See nix/modules/nixpkgs.nix (the user must import it)
            nixpkgs.overlays = [
              inputs.rust-overlay.overlays.default
            ];

            # Rust package
            packages.${crane.args.pname} = craneBuild.package;
            packages."${crane.args.pname}-doc" = craneBuild.doc;

            checks."${crane.args.pname}-clippy" = craneBuild.check;

            # Rust dev environment
            devShells.${crane.args.pname} = pkgs.mkShell {
              inputsFrom = [
                rustDevShell
              ];
            };
          };
      });
  };
}
