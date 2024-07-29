{ config, pkgs, lib, rust-project, ... }: {
  imports = [
    {
      options.crane.args = lib.mkOption {
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
    path = lib.mkOption {
      type = lib.types.path;
    };
    cargoToml = lib.mkOption {
      type = lib.types.attrsOf lib.types.raw;
      default = builtins.fromTOML (builtins.readFile ("${config.path}/Cargo.toml"));
    };
    hasBinaries = lib.mkOption {
      type = lib.types.bool;
      readOnly = true;
      description = ''
        Whether the crate has binaries or not.

        See <https://doc.rust-lang.org/cargo/reference/cargo-targets.html#binaries>
      '';
      default =
        lib.pathIsRegularFile "${config.path}/src/main.rs" ||
        lib.pathIsDirectory "${config.path}/src/bin" ||
        lib.hasAttr "bin" config.cargoToml;
    };
    autoWire = lib.mkOption {
      type = lib.types.bool;
      default = config.hasBinaries;
      defaultText = "true if the crate has binaries, false otherwise";
      description = ''
        Autowire the packages and checks for this crate on to the flake output.

        By default, crates with binaries will have their packages and checks wired.
      '';
    };
    crane = {
      args = {
        buildInputs = lib.mkOption {
          type = lib.types.listOf lib.types.package;
          default = [ ];
          description = "(Runtime) buildInputs for the cargo package";
        };
        nativeBuildInputs = lib.mkOption {
          type = lib.types.listOf lib.types.package;
          default = with pkgs; [
            pkg-config
            makeWrapper
          ];
          description = "nativeBuildInputs for the cargo package";
        };
      };
      extraBuildArgs = lib.mkOption {
        type = lib.types.lazyAttrsOf lib.types.raw;
        default = { };
        description = "Extra arguments to pass to crane's buildPackage function";
      };

      clippy.enable = lib.mkEnableOption "Add flake check for cargo clippy" // { default = true; };

      outputs =
        let
          inherit (rust-project) toolchain src crane-lib;
          inherit (config) crane cargoToml;

          name = cargoToml.package.name;
          version = cargoToml.package.version;
          description = cargoToml.package.description
            or (builtins.throw "Missing description in ${name}'s Cargo.toml");

          # Crane builder
          # NOTE: Is it worth exposing this entire attrset as a readOnly module
          # option?
          craneBuild = rec {
            args = crane.args // {
              inherit src version;
              pname = name;
              cargoExtraArgs = "-p ${name}";
              # glib-sys fails to build on linux without this
              # cf. https://github.com/ipetkov/crane/issues/411#issuecomment-1747533532
              strictDeps = true;
            };
            cargoArtifacts = crane-lib.buildDepsOnly args;
            buildArgs = args // {
              inherit cargoArtifacts;
              meta = (args.meta or { }) // {
                inherit description;
              };
            } // crane.extraBuildArgs;
            package = crane-lib.buildPackage buildArgs;

            check = crane-lib.cargoClippy (args // {
              inherit cargoArtifacts;
              cargoClippyExtraArgs = "--all-targets --all-features -- --deny warnings";
              meta = (args.meta or { }) // {
                description = "Clippy check for the ${name} crate";
              };
            });

            doc = crane-lib.cargoDoc (args // {
              inherit cargoArtifacts;
              RUSTDOCFLAGS = "-D warnings"; # The doc package should build only without warnings
              meta = (args.meta or { }) // {
                description = "Rust docs for the ${name} crate";
              };
            });
          };
        in
        {
          drv = {
            crate = lib.mkOption {
              type = lib.types.package;
              description = "The Nix package for the Rust crate";
              default = craneBuild.package;
            };
            doc = lib.mkOption {
              type = lib.types.package;
              description = "The Nix package for the Rust crate documentation";
              default = craneBuild.doc;
            };
            clippy = lib.mkOption {
              type = lib.types.package;
              description = "The Nix package for the Rust crate clippy check";
              default = craneBuild.check;
            };
          };

          packages = lib.mkOption {
            type = lib.types.lazyAttrsOf lib.types.package;
            default = lib.optionalAttrs config.autoWire {
              ${name} = config.crane.outputs.drv.crate;
              "${name}-doc" = config.crane.outputs.drv.doc;
            };
          };

          checks = lib.mkOption {
            type = lib.types.lazyAttrsOf lib.types.package;
            default = lib.optionalAttrs (config.autoWire && crane.clippy.enable) {
              "${name}-clippy" = config.crane.outputs.drv.clippy;
            };
          };
        };
    };
  };
}
