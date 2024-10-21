[![project chat](https://img.shields.io/badge/zulip-join_chat-brightgreen.svg)](https://nixos.zulipchat.com/#narrow/stream/446608-rust-flake)

# rust-flake

A simple flake module for Rust development, based on [Crane](https://crane.dev/). `rust-flake` is inspired by [`haskell-flake`](https://github.com/srid/haskell-flake).

## Progress

- [x] Simple module that works with single-crate projects
- [x] Multi-crate workspaces
- [ ] Tests

## Examples

- Single crates
    - https://github.com/srid/rust-nix-template
    - https://github.com/juspay/nix-rs
- Multi-crate workspace
    - https://github.com/juspay/omnix
    - https://github.com/juspay/superposition
- Desktop apps
    - https://github.com/srid/dioxus-desktop-template
    - https://github.com/juspay/omnix

## Comparison with other tools

| | rust-flake | [nix-cargo-integration](https://github.com/yusdacra/nix-cargo-integration) |
| --- | --- | --- |
| Stable over time | ✔️ | ✖️[^crane] |

[^crane]: `rust-flake` uses [crane](https://crane.dev/) directly, which is known to be stable. Whereas `nix-cargo-integration` uses `dream2nix` which is known to be unstable. See [here](https://matrix.to/#/!gcrYWdPsIUOFpXFDHB:matrix.org/$vJGlKFLKj4uRp-QkokK_0ISnnXHaXQ5tv7A_PcDYl7A?via=matrix.org&via=nixos.dev&via=goblin.sh) and [here](https://github.com/srid/rust-nix-template/pull/27)
