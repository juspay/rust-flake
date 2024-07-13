{ config, lib, ... }:

{
  rust-project.crates =
    let
      inherit (config.rust-project) cargoToml src;
    in
    if lib.hasAttr "workspace" (builtins.trace (builtins.toJSON cargoToml.workspace.members) cargoToml)
    then
    # FIXME: this requires impure
      lib.foldl'
        (acc: pathString:
          let
            path = src + "/${pathString}";
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
        path = src;
      };
    };
}
