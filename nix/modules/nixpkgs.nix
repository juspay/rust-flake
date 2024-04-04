# https://github.com/hercules-ci/flake-parts/issues/74#issuecomment-1513708722
{ inputs, flake-parts-lib, ... }: {
  options.perSystem = mkPerSystemOption ({ pkgs, system, ... }: {
    imports = [
      "${(flake-parts-lib.findInputByOutPath ./. inputs).nixpkgs}/nixos/modules/misc/nixpkgs.nix"
    ];
    nixpkgs.hostPlatform = system;
  });
}
