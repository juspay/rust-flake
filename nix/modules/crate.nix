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
      default = builtins.fromTOML (builtins.readFile (config.path + /Cargo.toml));
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

          # Crane builder
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
            } // crane.extraBuildArgs;
            package = crane-lib.buildPackage buildArgs;

            check = crane-lib.cargoClippy (args // {
              inherit cargoArtifacts;
              cargoClippyExtraArgs = "--all-targets --all-features -- --deny warnings";
            });

            doc = crane-lib.cargoDoc (args // {
              inherit cargoArtifacts;
            });
          };
        in
        {
          packages = lib.mkOption {
            type = lib.types.lazyAttrsOf lib.types.package;
            default = {
              ${name} = craneBuild.package;
              "${name}-doc" = craneBuild.doc;
            };
          };

          checks = lib.mkOption {
            type = lib.types.lazyAttrsOf lib.types.package;
            default = lib.mkIf crane.clippy.enable {
              "${name}-clippy" = craneBuild.check;
            };
          };
        };
    };
  };
}
