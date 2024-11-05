{ config, pkgs, lib, ... }:

{
  config.devShells.rust =
    let
      inherit (config.rust-project) toolchain crane;

    in
    pkgs.mkShell {
      name = "rust-flake-devshell";
      meta.description = "Rust development environment, created by rust-flake";
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
}
