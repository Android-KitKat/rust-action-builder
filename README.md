# Rust Action Builder

[![GitHub Stars](https://img.shields.io/github/stars/Android-KitKat/rust-action-builder?label=GitHub%20stars)](https://github.com/Android-KitKat/rust-action-builder)
[![Docker Stars](https://img.shields.io/docker/stars/android99/rust-action-builder?style=social&logo=docker)](https://hub.docker.com/r/android99/rust-action-builder)

[![Docker Image Version](https://img.shields.io/docker/v/android99/rust-action-builder/latest)](https://hub.docker.com/r/android99/rust-action-builder)
[![Docker Image Size](https://img.shields.io/docker/image-size/android99/rust-action-builder/latest)](https://hub.docker.com/r/android99/rust-action-builder)
[![Docker Image Pulls](https://img.shields.io/docker/pulls/android99/rust-action-builder)](https://hub.docker.com/r/android99/rust-action-builder)

Rust builder for Action on Linux.

Can be used for self-hosted runners on Linux.

## Environments

- [Debian](https://www.debian.org) >= 12
- [Node.js](https://nodejs.org) >= 24
- [Rust](https://rust-lang.org) >= 1.89

## Supported targets

### Windows

- `x86_64-pc-windows-gnullvm`
- `aarch64-pc-windows-gnullvm`

### Linux

- `x86_64-unknown-linux-musl`
- `x86_64-unknown-linux-gnu`
- `aarch64-unknown-linux-musl`
- `aarch64-unknown-linux-gnu`

### macOS

- `x86_64-apple-darwin`
- `aarch64-apple-darwin`

## Example

Just specify [jobs.<job_id>.container.image](https://docs.github.com/actions/reference/workflows-and-actions/workflow-syntax#jobsjob_idcontainerimage) as `android99/rust-action-builder`.

```yaml
name: Build

on:
  push:
    branches: [main]
  workflow_dispatch: {}

jobs:
  build:
    name: Build ${{ matrix.os }} Platform
    runs-on: ubuntu-latest
    container:
      image: android99/rust-action-builder
    env:
      TARGET: ${{ matrix.target }}
      BINARY: ${{ matrix.binary }}

    strategy:
      matrix:
        fail-fast: false
        include:
          - os: Windows
            target: x86_64-pc-windows-gnullvm
            binary: app.exe
            artifact: app-windows-x86_64

          - os: Linux
            target: x86_64-unknown-linux-musl
            binary: app
            artifact: app-linux-x86_64

          - os: macOS
            target: universal-apple-darwin
            binary: app
            artifact: app-macos-universal

    steps:
      - name: Checkout
        uses: actions/checkout@v6

      - name: Rust Cache
        uses: Swatinem/rust-cache@v2

      - name: Build Binary
        run: |
          if [ "$TARGET" = universal-apple-darwin ]; then
            cargo build -r --target x86_64-apple-darwin --target aarch64-apple-darwin
            mkdir -p "target/$TARGET/release"
            lipo -create \
              "target/x86_64-apple-darwin/release/$BINARY" \
              "target/aarch64-apple-darwin/release/$BINARY" \
              -output "target/$TARGET/release/$BINARY"
          else
            cargo build -r --target "$TARGET"
          fi

      - name: Upload Artifact
        uses: actions/upload-artifact@v7
        with:
          name: ${{ matrix.artifact }}
          path: target/${{ matrix.target }}/release/${{ matrix.binary }}
          if-no-files-found: error
```

## Acknowledgements

- [joseluisq/rust-linux-darwin-builder](https://github.com/joseluisq/rust-linux-darwin-builder)
- [mstorsjo/llvm-mingw](https://github.com/mstorsjo/llvm-mingw)
