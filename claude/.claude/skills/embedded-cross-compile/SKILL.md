---
name: embedded-cross-compile
description: Use when cross-compiling for another architecture, building for embedded or bare-metal targets, producing a binary for field devices (Raspberry Pi, MCUs), working with no_std, DDS/microXRCE/micro-ROS, or flashing/deploying to hardware.
---

# Embedded & Cross-Compile

## Overview

Target-selection and static-linking judgment are usually sound. The gates are two: making the build reproducible by another operator (the toolchain is documented, not tribal knowledge), and never touching hardware without a human saying go.

<HARD-GATE>
1. **Target triple + toolchain documented per project, where an operator will find it** — the exact triple, the cross-linker/sysroot and how to install it, and the one build command, in a README or BUILD note (not only a buried `.cargo/config.toml` comment). "It builds on my machine" is not a shippable build.
2. **NEVER flash, deploy, or run on hardware without explicit user confirmation.** Building an artifact is fine; `probe-rs run`, `cargo flash`, `dfu-util`, scp-to-device, or anything that writes to or executes on a physical target stops and asks first. State which device and what will be written.
</HARD-GATE>

## Host vs target — be honest about what you verified

- Say what ran WHERE. "Builds for the target" (a static ELF confirmed with `file`) is not "runs on the target." Don't claim a target run you didn't do.
- If you can't execute on real hardware, verify structurally (arch/linkage via `file`, `readelf`) and/or in an emulator (QEMU for full-system Linux, Renode for MCU peripheral fidelity) — and label it as such. Do NOT force-start infrastructure (Docker, a device agent) just to fake a runtime check.
- Tests split: pure logic runs on the host; hardware-dependent paths run on target or emulator. Keep the logic host-testable.

## Toolchain discipline

- Pick the triple deliberately and say why: `-musl` for a fully static, glibc-independent field binary; `-gnu` when you need glibc/dynamic linking. Bare-metal is `*-none-*` (e.g. `thumbv7em-none-eabihf`).
- Hosted-target tools (`cargo-zigbuild`, `cross`) are for Linux/Win/Mac cross-builds, NOT bare-metal firmware. Note `cross` has been effectively unmaintained since 2023 (Docker-based); `cargo-zigbuild` is maintained but hosted-only.
- Resource constraints on bare metal: `no_std` (+ `alloc` only if you truly need a heap), watch stack/static sizes, avoid unbounded allocation. `defmt` for logging over RTT; `probe-rs` is the current flash/debug standard (OpenOCD the fallback).

## Red flags

| Flag | Reality |
|---|---|
| Build steps only in shell history / one machine | Document the triple + toolchain + command where an operator finds it |
| "Deployed it to the device" without being asked | Stop — flashing/running on hardware needs explicit confirmation |
| Claiming it "runs on the Pi" after only `cargo build` | You verified a build, not a run — say so |
| Force-starting Docker/QEMU to emulate silently | Fine to emulate; label it, don't fake, don't auto-start heavy infra |
| Bare-metal build reaching for `cross`/zigbuild | Those are hosted-target tools; use the proper `*-none-*` toolchain |

Target/toolchain specifics (embedded-hal 1.0, probe-rs, ROS 2 / Fast DDS / micro-XRCE-DDS, Arm toolchains, emulators): see [references/ecosystem.md](references/ecosystem.md).
