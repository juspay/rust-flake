{ config, pkgs, lib, rust-project, ... }: {
  imports = [
    {
      options.crane.args = lib.mkOption {
        default = { };
        type = lib.types.submoduleWith {
          modules = [
            { freeformType = lib.types.attrsOf lib.types.raw; }
            rust-project.defaults.perCrate.crane.args
          ];
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
      description = "The path to the crate folder";
    };
    cargoToml = lib.mkOption {
      type = lib.types.attrsOf lib.types.raw;
      description = "The parsed Cargo.toml file";
      default = builtins.fromTOML (builtins.readFile (config.path + "/Cargo.toml"));
      defaultText = lib.literalExpression ''
        fromTOML (readFile (path + "/Cargo.toml"))
      '';
    };
    autoWire =
      let
        outputTypes = [ "crate" "doc" "clippy" ];
      in
      lib.mkOption {
        type = lib.types.listOf (lib.types.enum outputTypes);
        description = ''
          List of flake output types to autowire.

          Using an empty list will disable autowiring entirely,
          enabling you to manually wire them using
          `config.rust-project.crates.<name>.crane.outputs`.
        '';
        default = outputTypes;
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
          defaultText = lib.literalExample ''
            with pkgs; [ pkg-config makeWrapper ]
          '';
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
          inherit (rust-project) src crane-lib;
          inherit (config) crane cargoToml;

          name = cargoToml.package.name;
          # version = cargoToml.package.version;
          description = cargoToml.package.description
            or (builtins.throw "Missing description in ${name}'s Cargo.toml");

          # Crane builder
          # NOTE: Is it worth exposing this entire attrset as a readOnly module
          # option?
          craneBuild = rec {
            args = crane.args // {
              inherit src;
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
              defaultText = lib.literalMD "_computed with crane_";
            };
            doc = lib.mkOption {
              type = lib.types.package;
              description = "The Nix package for the Rust crate documentation";
              default = craneBuild.doc;
              defaultText = lib.literalMD "_computed with crane_";
            };
            clippy = lib.mkOption {
              type = lib.types.package;
              description = "The Nix package for the Rust crate clippy check";
              default = craneBuild.check;
              defaultText = lib.literalMD "_computed with crane_";
            };
          };

          packages = lib.mkOption {
            type = lib.types.lazyAttrsOf lib.types.package;
            description = "All Nix packages for the Rust crate";
            default = lib.mergeAttrs
              (lib.optionalAttrs (lib.elem "crate" config.autoWire) {
                ${name} = config.crane.outputs.drv.crate;
              })
              (lib.optionalAttrs (lib.elem "doc" config.autoWire) {
                "${name}-doc" = config.crane.outputs.drv.doc;
              });
            defaultText = lib.literalMD ''
              lib.mergeAttrs
                (optionalAttrs (elem "crate" config.autoWire) {
                  "''${name}" = config.crane.outputs.drv.crate;
                })
                (optionalAttrs (elem "doc" config.autoWire) {
                  "''${name}-doc" = config.crane.outputs.drv.doc;
                })
            '';
          };

          checks = lib.mkOption {
            type = lib.types.lazyAttrsOf lib.types.package;
            description = "All Nix flake checks for the Rust crate";
            default = lib.optionalAttrs (lib.elem "clippy" config.autoWire && crane.clippy.enable) {
              "${name}-clippy" = config.crane.outputs.drv.clippy;
            };
            defaultText = lib.literalExample ''
              optionalAttrs (elem "clippy" config.autoWire && crane.clippy.enable) {
                "''${name}-clippy" = config.crane.outputs.drv.clippy;
              }
            '';
          };
        };
    };
  };
}
