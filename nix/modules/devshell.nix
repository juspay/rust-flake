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
      ] ++ lib.concatMap (crate: crate.crane.args.buildInputs) (lib.attrValues config.rust-project.crates);
      packages = [
        toolchain
      ] ++ lib.concatMap (crate: crate.crane.args.nativeBuildInputs) (lib.attrValues config.rust-project.crates);
    };
}
