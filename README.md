# opencv-staticlib

Pre-built OpenCV libraries for multiple target platforms.

## Platform builds

| Directory | Architecture | OpenCV version | Toolchain |
|---|---|---|---|
| `aarch64/` | ARM64 | 4.11.0 | Linux cross-compile |
| `x86_64/` | x86-64 | 4.11.0 | Linux native |
| `cortexa9t2hf-neon-oe/` | ARMv7 hard-float | 4.5.2 | Yocto/OpenEmbedded |

> **Note:** The `cortexa9t2hf-neon-oe` build is on OpenCV 4.5.2 — intentionally different from the
> other platforms. It is built via a Yocto recipe and tracks the version provided by that BSP.
> The `aarch64` and `x86_64` builds are maintained separately and are on the latest 4.11.x release.

## Branches

| Branch | glibc | Use for |
|---|---|---|
| `linux-4.11-shared-ubuntu18` | 2.27 | Ubuntu 18/20/22/24, Debian 10, cameras — prefer this |
| `linux-4.11-shared` | 2.35 | Ubuntu 22/24 only |

Prefer `linux-4.11-shared-ubuntu18` — it is broadly compatible and runs on all camera targets.
