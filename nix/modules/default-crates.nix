{ config, lib, ... }:

# Define a default for `rust-project.crates` by reading Cargo.toml files
{
  rust-project.crates =
    let
      inherit (config.rust-project) cargoToml src;
    in
    if lib.hasAttr "workspace" cargoToml
    then
    # Read workspace crates from Cargo.toml
      lib.foldl'
        (acc: pathString:
          let
            path =
              lib.cleanSourceWith {
                name = builtins.baseNameOf pathString;
                src = "${src}/${pathString}";
                # TODO(DRY): Consolidate with that of flake-module.nix
                filter = path: type:
                  (config.rust-project.crateNixFile != null && lib.hasSuffix "/${config.rust-project.crateNixFile}" path) ||
                  (config.rust-project.crane-lib.filterCargoSources path type);
              };
            cargoPath = "${path}/Cargo.toml";
            cargoToml = builtins.fromTOML (builtins.readFile cargoPath);
            name = cargoToml.package.name;
            crateNixFilePath =
              if config.rust-project.crateNixFile == null
              then null
              else
                let p = "${path}/${config.rust-project.crateNixFile}"; in
                if lib.pathIsRegularFile p then p else null;
          in
          acc // {
            ${name} = {
              # Import the .nix file from the crate directory, if asked for.
              imports = lib.optionals (crateNixFilePath != null) [
                (builtins.traceVerbose "rust-flake: Using ${crateNixFilePath}" crateNixFilePath)
              ];
              path = lib.mkDefault path;
            };
          }
        )
        { }
        cargoToml.workspace.members
    else
    # Read single package crate from top-level Cargo.toml
      {
        ${cargoToml.package.name} = {
          path = lib.mkDefault src;
          autoWire = true;
        };
      };
}
