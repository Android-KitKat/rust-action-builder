FROM joseluisq/rust-linux-darwin-builder:1.89.0

ARG TARGETPLATFORM
ARG LLVM_MINGW_VERSION=20260602

ENV LLVM_MINGW_VERSION=$LLVM_MINGW_VERSION

RUN <<EOF
set -eux

case $TARGETPLATFORM in
  linux/amd64)
    LLVM_MINGW="llvm-mingw-$LLVM_MINGW_VERSION-ucrt-ubuntu-22.04-x86_64.tar.xz"
    ;;
  linux/arm64)
    LLVM_MINGW="llvm-mingw-$LLVM_MINGW_VERSION-ucrt-ubuntu-22.04-aarch64.tar.xz"
    ;;
  *)
    echo "Unsupported platform"
    exit 1
    ;;
esac

curl -fsSL https://deb.nodesource.com/setup_24.x | bash
apt install -y nodejs
apt clean
rm -rf /var/lib/apt/lists/*

curl -fsSL "https://github.com/mstorsjo/llvm-mingw/releases/download/$LLVM_MINGW_VERSION/$LLVM_MINGW" | \
  tar -xJ --one-top-level=/usr/local/llvm-mingw --strip-components=1
rustup target add x86_64-pc-windows-gnullvm aarch64-pc-windows-gnullvm
rm -f /root/.cargo/config
EOF

ENV PATH=$PATH:/usr/local/llvm-mingw/bin

COPY cargo.toml /root/.cargo/config.toml
