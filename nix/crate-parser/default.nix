{ pkgs ? import <nixpkgs> { }, lib ? pkgs.lib, ... }:

# TODO: Handle advanced globs if encountered, this should handle most cases.
# Simple approach: find all directories with Cargo.toml
members: src:
lib.concatMap
  (member:
  if lib.hasSuffix "/*" member then
  # Handle glob patterns like "crates/*"
    let
      baseDir = lib.removeSuffix "/*" member;
      fullBaseDir = "${src}/${baseDir}";
    in
    if lib.pathIsDirectory fullBaseDir then
      map (name: "${baseDir}/${name}")
        (lib.filter
          (name: lib.pathIsRegularFile "${fullBaseDir}/${name}/Cargo.toml")
          (builtins.attrNames (builtins.readDir fullBaseDir)))
    else [ ]
  else if member == "." then
  # Handle root workspace
    if lib.pathIsRegularFile "${src}/Cargo.toml" then [ "." ] else [ ]
  else
  # Handle explicit paths
    if lib.pathIsRegularFile "${src}/${member}/Cargo.toml" then [ member ] else [ ]
  )
  members
