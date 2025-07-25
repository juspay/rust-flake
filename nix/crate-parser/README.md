# `crate-parser`
**crate-parser** provides parsers for Rust-associated files.

## Features

- Currently, the main available function is [`findCrates`](./default.nix), which processes `workspace.members` globs from `Cargo.toml`.

For example:
```toml
[workspace]
members = [ "crates/*" ]
````

This will be handled correctly by `findCrates`, resolving the paths accordingly.

## Contributing

Feel free to create a PR to improve **crate-parser** — contributions are welcome!
