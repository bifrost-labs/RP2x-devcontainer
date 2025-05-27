# https://hub.docker.com/_/rust/
# https://github.com/rust-lang/docker-rust

ARG RUST_VERSION=1.87.0
ARG DEBIAN_VERSION=bookworm

FROM rust:${RUST_VERSION}-slim-${DEBIAN_VERSION}

RUN apt-get update && export DEBIAN_FRONTEND=noninteractive \
    && apt-get -y install --no-install-recommends curl gpg

# https://software.opensuse.org/download.html?project=shells%3Afish%3Arelease%3A4&package=fish
RUN echo 'deb http://download.opensuse.org/repositories/shells:/fish:/release:/4/Debian_12/ /' | tee /etc/apt/sources.list.d/shells:fish:release:4.list \
    && curl -fsSL https://download.opensuse.org/repositories/shells:fish:release:4/Debian_12/Release.key | gpg --dearmor | tee /etc/apt/trusted.gpg.d/shells_fish_release_4.gpg > /dev/null

RUN apt-get update && export DEBIAN_FRONTEND=noninteractive \
    && apt-get -y install --no-install-recommends bat dpkg fish git git-lfs less libudev-dev pkg-config sudo \
    && rm -rf /var/lib/apt/lists/*

# https://dandavison.github.io/delta/installation.html
RUN set -eux; \
    dpkgArch="$(dpkg --print-architecture)"; \
    case "${dpkgArch##*-}" in \
        amd64) debArch='amd64';; \
        arm64) debArch='arm64';; \
        *) echo >&2 "unsupported architecture: ${dpkgArch}"; exit 1 ;; \
    esac; \
    export _version=0.18.2; \
    curl -L -o /tmp/git-delta.deb https://github.com/dandavison/delta/releases/download/${_version}/git-delta_${_version}_${debArch}.deb \
    && dpkg -i /tmp/git-delta.deb \
    && rm /tmp/git-delta.deb

# additional cargo installs for later: cargo-binstall, probe-rs-tools
RUN rustup default $RUST_VERSION \
    && rustc --version \
    && rustup component add clippy llvm-tools-preview rustfmt \
    # targets for RP2040 and RP2350
    && rustup target add thumbv8m.main-none-eabihf riscv32imac-unknown-none-elf thumbv6m-none-eabi \
    && cargo install cargo-binutils flip-link pest-language-server \
    # elf2uf2-rs: use forked repo until this PR is merged and published to crates.io:
    # https://github.com/JoNil/elf2uf2-rs/pull/39
    && cargo install --git https://github.com/ninjasource/elf2uf2-rs/  --branch pico2-support \
    && rm -rf $CARGO_HOME/registry/

# same vscode username as in devcontainer.json
ARG DEVUSER=vscode

# Create the user
# https://code.visualstudio.com/remote/advancedcontainers/add-nonroot-user
ARG USER_UID=1000
ARG USER_GID=$USER_UID

RUN groupadd --gid $USER_GID $DEVUSER \
    && useradd --uid $USER_UID --gid $USER_GID -m $DEVUSER \
    && echo $DEVUSER ALL=\(root\) NOPASSWD:ALL > /etc/sudoers.d/$DEVUSER \
    && chmod 0440 /etc/sudoers.d/$DEVUSER

COPY --chown=${DEVUSER}:${DEVUSER} dotfiles/ /home/$DEVUSER/

USER $DEVUSER
SHELL ["/usr/bin/fish", "-l"]
