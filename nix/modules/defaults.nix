# Defaults used in the `rust-project`
{ lib, ... }:
{
  options.rust-project.defaults.perCrate.crane.args = lib.mkOption {
    default = { };
    type = lib.types.deferredModule;
    description = ''
      Default arguments for `config.rust-project.crates.<name>.crane.args`
    '';
  };
}
