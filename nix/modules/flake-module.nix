inputs:
{ self, lib, flake-parts-lib, ... }:

let
  inherit (flake-parts-lib)
    mkPerSystemOption;
in
{
  options = {
    perSystem = mkPerSystemOption
      (top@{ config, self', pkgs, system, ... }: {
        imports = [

          {
            rust-project.crates =
              let
                inherit (config.rust-project) cargoToml;
              in
              if lib.hasAttr "workspace" (builtins.trace (builtins.toJSON cargoToml.workspace.members) cargoToml)
              then
              # FIXME: this requires impure
                lib.foldl'
                  (acc: pathString:
                    let
                      path = self + "/${pathString}";
                      # Get name from last path component of pathString (split by '/', then taken last)
                      # name = lib.lists.last (lib.strings.splitString "/" pathString);
                      cargoPath = builtins.toPath (path + "/Cargo.toml");
                      cargoToml = builtins.fromTOML (builtins.readFile cargoPath);
                      name = cargoToml.package.name;
                    in
                    acc // { ${name} = { path = lib.mkDefault path; }; }
                  )
                  { }
                  cargoToml.workspace.members
              else {
                ${cargoToml.package.name} = {
                  path = self;
                };
              };
          }
        ];
        options = {
          # TODO: Multiple projects
          rust-project = {
            crates = lib.mkOption {
              description = ''Attrset of crates pointing to the local path, which has its Cargo.toml file'';
              type = lib.types.attrsOf (lib.types.submoduleWith {
                modules = [ ./crate.nix ];
                specialArgs = { inherit (config) rust-project; };
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
        config =
          let
            inherit (config.rust-project) toolchain crane;
            rustDevShell = pkgs.mkShell {
              shellHook = ''
                # For rust-analyzer 'hover' tooltips to work.
                export RUST_SRC_PATH="${toolchain}/lib/rustlib/src/rust/library";
              '';
              buildInputs = [
                pkgs.libiconv
              ] ++ lib.mapAttrsToList (_: crate: crate.crane.args.buildInputs) config.rust-project.crates;
              packages = [
                toolchain
              ] ++ lib.mapAttrsToList (_: crate: crate.crane.args.nativeBuildInputs) config.rust-project.crates;
            };
          in
          {
            # See nix/modules/nixpkgs.nix (the user must import it)
            nixpkgs.overlays = [
              inputs.rust-overlay.overlays.default
            ];

            # lib.mapAttrs over config.rust-project.crates returning its outputs.packages (combined)
            packages =
              lib.mkMerge
                (lib.mapAttrsToList (name: crate: crate.crane.outputs.packages) config.rust-project.crates);

            # Rust dev environment
            devShells.rust = rustDevShell;
          };
      });
  };
}
