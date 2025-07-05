{ inputs, ... }:
{
  imports = [
    inputs.rust-flake.flakeModules.default
    inputs.rust-flake.flakeModules.nixpkgs
  ];

  perSystem = { ... }: {
    # for `members = ["crates/*]` or any glob pattern,
    # only main/binary crate is required to be defined.
    # rest is taken care of by rust-flake.

    # for complex e.g check hyperswitch: <https://github.com/juspay/hyperswitch>
    rust-project = {
      crates = {
        crate-a.path = (inputs.self) + /crates/crate-a;
      };
    };
  };
}
