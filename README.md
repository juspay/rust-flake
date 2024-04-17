# rust-flake

WIP: Like the famous `haskell-flake`, but for Rust, using [Crane](https://crane.dev/) underneath.

## Progress

- [x] Simple module that works with single-crate projects
- [ ] Multi-crate workspaces
- [ ] Multiple projects
- [ ] Examples & tests

## Examples

- https://github.com/srid/rust-nix-template
- https://github.com/juspay/nix-rs

## Comparison with other tools

| | rust-flake | [nix-cargo-integration](https://github.com/yusdacra/nix-cargo-integration) |
| --- | --- | --- |
| Stable over time | ✔️ | ✖️[^crane] |

[^crane]: `rust-flake` uses [crane](https://crane.dev/) directly, which is known to be stable. Whereas `nix-cargo-integration` uses `dream2nix` which is know to be unstable. See [here](https://matrix.to/#/!gcrYWdPsIUOFpXFDHB:matrix.org/$vJGlKFLKj4uRp-QkokK_0ISnnXHaXQ5tv7A_PcDYl7A?via=matrix.org&via=nixos.dev&via=goblin.sh) and [here](https://github.com/srid/rust-nix-template/pull/27)
