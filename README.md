# DevContainer for Embedded Raspberry RP2X Micro Controllers

Produce and publishes docker [dev containers](https://containers.dev/implementors/json_reference/)
with embedded compiler toolchains pre-installed.

The docker images published can be installed as [pre-built VSCode dev container image](https://code.visualstudio.com/docs/devcontainers/containers#_prebuilding-dev-container-images).

## Rust

Add this to your `.devcontainer/devcontainer.json` in your repo (adjust version):

```json
  {
    "image": "ghcr.io/bifrost-labs/RP2x-devcontainer/rp2x-rust:1.87.0-rc1",
  }
```
