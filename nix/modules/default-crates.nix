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
                filter = path: type:
                  (config.rust-project.crane-lib.filterCargoSources path type);
              };
            cargoPath = "${path}/Cargo.toml";
            cargoToml = builtins.fromTOML (builtins.readFile cargoPath);
            name = cargoToml.package.name;
          in
          acc // {
            ${name} = {
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
