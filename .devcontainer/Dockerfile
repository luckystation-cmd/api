FROM ubuntu:latest

USER root
ENV USER root

# Install package dependencies.
RUN apt-get update \
    && apt-get install -y \
    apt-utils curl gcc lld clang libssl-dev libpq-dev postgresql-client pkg-config \
    && rm -rf /var/lib/apt/lists/*

# Install Rust
RUN curl https://sh.rustup.rs -sSf > /tmp/rustup-init.sh \
    && chmod +x /tmp/rustup-init.sh \
    && sh /tmp/rustup-init.sh -y \
    && rm -rf /tmp/rustup-init.sh
ENV PATH "$PATH:~/.cargo/bin"

# Update the local crate index
RUN ~/.cargo/bin/cargo search

RUN ~/.cargo/bin/cargo install --version="~0.8" sqlx-cli --no-default-features --features rustls,postgres

# Install rust 1.81.0
RUN ~/.cargo/bin/rustup default 1.81.0
