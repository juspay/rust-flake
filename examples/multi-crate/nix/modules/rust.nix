{ inputs, ... }:
{
  imports = [
    inputs.rust-flake.flakeModules.default
    inputs.rust-flake.flakeModules.nixpkgs
  ];
  perSystem = { config, lib, ... }: {
    rust-project = {
      crates = {
        math-utils.path = (inputs.self) + /math-utils;
        calculator = {
          # few intentional errors are left in calculator crate.
          # nix flake check will catch them. if clippy is enabled,
          crane.clippy.enable = false;
          path = (inputs.self) + /calculator;
        };
        root.path = (inputs.self) + /root;
      };
      # For complex projects, Give a look at:
      # omnix: <https://github.com/juspay/omnix>
      # superposition: <https://github.com/juspay/omnix>
      src =
        let
          # Like crane's filterCargoSources, but doesn't blindly include all TOML files!
          filterCargoSources = path: type:
            config.rust-project.crane-lib.filterCargoSources path type
            && !(lib.hasSuffix ".toml" path && !lib.hasSuffix "Cargo.toml" path);
        in
        lib.cleanSourceWith {
          src = inputs.self;
          filter = path: type:
            filterCargoSources path type
            || "${inputs.self}/flake.nix" == path
            || "${inputs.self}/flake.lock" == path
            || "${inputs.self}/rust-toolchain.toml" == path
          ;
        };
    };
  };
}
