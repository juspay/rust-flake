{ pkgs ? import <nixpkgs> { }, lib ? pkgs.lib, ... }:
let
  findCrates = pkgs.callPackage ./. { };

  cargoMembersTest = {
    testStar = {
      expr = findCrates [ "crates/*" ] ./test;
      expected = [ "crates/crate-a" ];
    };

  };
  # Like lib.runTests, but actually fails if any test fails.
  runTestsFailing = tests:
    let
      res = lib.runTests tests;
    in
    if res == builtins.trace "✅ All tests passed" [ ]
    then res
    else builtins.throw "Some tests failed: ${builtins.toJSON res}" res;
in
{
  "cargo.members" = runTestsFailing cargoMembersTest;
}
