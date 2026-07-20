# Embedded & Cross-Compile Ecosystem Reference (verified July 2026)

Version-sensitive facts backing SKILL.md. Embedded/cross tooling moves fast — treat versions as "as of early July 2026," verify at authoring time. The recurring hazard is training data that (a) assumes "mature = 1.0" where it isn't, (b) reaches for a hosted-target tool on bare metal, or (c) cites renamed/archived tools. Facts tagged **[settled]** vs **[in-flight]** where it matters.

## Version reality check

| Crate/tool | Version (Jul 2026) | 1.0? |
|---|---|---|
| **embedded-hal** (+ -async / -bus / -nb) | **1.0.0** (2024-01-09) | **yes — no 2.0 planned**, future work is additive 1.x |
| defmt | **1.0.1** | yes (no 2.0 intended; MSRV 1.76) |
| esp-hal | **1.0.0** (2025-10-30) | yes — first vendor-backed 1.0 |
| Embassy (embassy-executor) | **0.10.0** (2026-03-20) | **no — still 0.x, pin per-crate** |
| probe-rs / probe-rs-tools | **0.31.0** (2026-01-17) | **no — still 0.x** |
| heapless | 0.4.x | no |
| embedded-alloc | 0.7.0 (**renamed from `alloc-cortex-m`**) | no |
| Fast DDS | **3.6.2** (3.x LTS line) | on 3.x |
| Micro XRCE-DDS Agent/Client | **3.0.x** (Agent v3.0.1) | on 3.x |

**Guidance:** Embassy and probe-rs are production-*used* but carry **no 1.0 semver promise** — pin exact minors, expect occasional 0.x breaks. Do not call them "1.0"/"stable API." defmt / embedded-hal / esp-hal *are* 1.0+.

## embedded-hal 1.0 — the anchor [settled]
- **1.0.0 shipped 2024-01-09**, stable trait foundation, **no 2.0 planned**. Companions same day: **embedded-hal-async** (async traits), **-nb** (`nb`/non-blocking), **-bus** (`SpiDevice`/`I2cDevice` bus-sharing via `RefCell`/`Mutex`/atomic — don't hand-roll bus sharing).
- **Async traits on stable Rust since 1.75** (RPITIT / `async fn` in traits): eh-async needs no heap, no `dyn`, no `async-trait` macro. This is why async embedded became real.
- Migrated HALs: esp-hal, rp-hal, nrf-hal, stm32 HALs, Embassy HALs. Crates still on 0.2 with no 1.0 path are a maintenance red flag; **embedded-hal-compat** shims the gap.

## Cross-compilation tool selection — bare-metal vs hosted (the conflation trap)

| Target class | Tool | Notes |
|---|---|---|
| **Bare-metal MCU** (`*-none-*`) | `rustup target add` + probe-rs runner | **Never** `cross`/`cargo-zigbuild` here. |
| **Hosted Linux/Win/mac cross** | **`cargo-zigbuild`** (lightest) or **`cross`** | zigbuild for light-C-dep/pure-Rust + glibc pinning; cross for heavy `*-sys` build scripts. |

- **`cross` (cross-rs/cross)** — Docker/Podman images with toolchains preinstalled; cross-tests via QEMU user-mode. **Stale correction: last release is still v0.2.5 (2024-02-04), unchanged ~2.5 yr, no 0.3.0.** `main` has ~684 unreleased commits; many install from git. Hard-requires a container runtime. Don't claim it's freshly released. **[release frozen; alive on main]**
- **`cargo-zigbuild` (rust-cross/cargo-zigbuild)** — **0.22.3 (2026-04-25)**, actively released. Uses `zig cc` as linker/C-cross-compiler. Superpower: **glibc version targeting** (`--target aarch64-unknown-linux-gnu.2.17`). **Hosted-target only — NOT `*-none-*` bare-metal.** [settled]
- **build-std is still nightly-only/unstable** (`-Zbuild-std=core,alloc` + `rust-src`), needed for Tier 3 targets with no prebuilt `core`. RFCs #3874/#3875 mid-flight, no stabilization date. Prefer a Tier 2 target when one exists. **[not stable; timeline in-flight]**
- **musl static-linking flip is in-flight, NOT shipped:** `x86_64-unknown-linux-musl` (Tier 2) **still statically links by default**; the enabling warn-lint (rust PR #144513) was still open 2026-06-13. Set `+crt-static`/`-crt-static` explicitly **per-target** in `.cargo/config.toml [target.<triple>]`, never via blanket `RUSTFLAGS` (breaks proc-macros/build scripts — rust #71651). musl pitfalls: `openssl-sys` → `vendored` or switch to **rustls**. **[in-flight]**

## Common target triples [settled]

| Triple | Chip / use |
|---|---|
| `thumbv6m-none-eabi` | Cortex-M0/M0+ (no HW float) |
| `thumbv7m-none-eabi` | Cortex-M3 |
| `thumbv7em-none-eabi` / **`-eabihf`** | Cortex-M4/M7; `hf` (hard-float) correct when FPU used (M4F/M7F). `eabi` vs `eabihf` wrong = silent perf loss or link/ABI mismatch |
| `thumbv8m.base-none-eabi` / `thumbv8m.main-none-eabi[hf]` | Cortex-M23 / M33·M55 |
| `riscv32imac-unknown-none-elf` (imc/imafc) | RISC-V MCUs (ESP32-C/-P) |
| `riscv64gc-unknown-none-elf`, `aarch64-unknown-none[-softfloat]` | higher-end / Cortex-A bare metal |
| `aarch64-unknown-linux-gnu` | **Tier 1 w/ host tools** (since 1.61) — hosted Linux |
| `aarch64-pc-windows-msvc` | **promoted to Tier 1 in Rust 1.91** (2025-10-30) |

The triple encodes ISA + FPU + ABI; docs must state the exact triple and *why* (chip → core → float). Add with `rustup target add`; C-side `--float-abi`/`-mfpu` must agree with Rust `eabihf` vs `eabi` when linking Rust + C on one MCU.

## Flashing / debugging: probe-rs vs OpenOCD

- **probe-rs 0.31.0** (still 0.x) — Rust-native flash + debug for ARM (Cortex-M/-A) + RISC-V over ST-Link/J-Link/CMSIS-DAP. A *library*. Front-ends: `cargo flash` (flash only), `cargo embed` (flash + RTT + `Embed.toml`), **`probe-rs run`** (flash, run, stream defmt/RTT, catch panics, exit with target's code — the standard Cargo `runner`). **probe-rs/embedded-test** = on-target `#[test]` harness.
- **Stale correction: `probe-run` is deprecated + archived** (maintenance 2023-10-11, repo archived 2024-01-30, final v0.3.11). Replacement is **`probe-rs run`**. A model emitting a `probe-run` runner is outdated.
- **OpenOCD is not obsolete** — still (a) faster at flashing, (b) more mature GDB single-stepping, (c) covers far more legacy/exotic silicon lacking a probe-rs flash-algorithm. probe-rs = default for Rust; OpenOCD = fallback for unsupported silicon / rock-solid GDB stepping.
- **`probe-rs run` / `cargo embed` / `cargo flash` all write to real hardware** — the "NEVER flash without confirmation" gate. `cargo build` is safe/unrestricted; the flash step is the boundary. Same class as `esptool write_flash`, `st-flash write`, `dfu-util`, `openocd ... program`, J-Link download.

## no_std / alloc discipline [settled]
- Bare-metal is `#![no_std]` + `#![no_main]` + a `#[panic_handler]` (usually `panic-probe`/`panic-halt`) + `cortex-m-rt`'s `#[entry]`.
- **Default is "no heap":** use **`heapless`** (fixed-capacity `Vec<T,N>`/`String<N>`/`spsc::Queue`/`pool` in static/stack memory, zero dynamic alloc, no fragmentation) whenever capacity is bounded. Reach for it before any allocator.
- If a heap is truly needed, add a `#[global_allocator]` — a menu, not a default: **`embedded-alloc` 0.7.0** (WG, renamed from `alloc-cortex-m`), **`talc` 5.0.4**, `linked_list_allocator`, `emballoc`. Then `extern crate alloc;`. Cost: fragmentation + nondeterministic latency.
- **`critical-section`** — portable interrupt-safe critical sections / `Mutex`; HALs provide the platform impl.

## Async frameworks & ESP notes
- **Embassy** — dominant async/await bare-metal framework; each `async fn` compiles to a state machine sharing one stack, replacing an RTOS. Statically allocated, **no heap**, compiles on stable Rust. First-party HALs: embassy-stm32 (0.6.0), embassy-nrf, embassy-rp (0.10.0), embassy-mspm0, embassy-mcxa. **Not a single 1.0** — pin individual crates. **RTIC** is the other idiomatic choice (priority-based interrupt scheduling, no async) — Embassy for async-first, RTIC for hard-real-time interrupt priorities.
- **ESP split (commonly mis-stated):** RISC-V ESP chips (C3/C6/H2, P4) build on **upstream** Rust, no fork, **Tier 2**. **Xtensa** chips (ESP32, S2, S3) **still require Espressif's forked LLVM + `espup`**, **Tier 3**. Don't say "just use upstream Rust for ESP32" — only for RISC-V parts. **esp-hal 1.0.0** (2025-10-30) is stable core; some features behind an `unstable` flag.
- **Ferrocene 26.02.0** — TÜV SÜD-qualified compiler (ISO 26262 ASIL D, IEC 61508 SIL 3, IEC 62304 Class C) plus a certified subset of `core` (ASIL B / SIL 2).

## C/C++ cross toolchains — renames [settled on rename]

| Tool | Fact |
|---|---|
| **Arm GNU Toolchain** (`arm-none-eabi-gcc`) | Arm publishes directly now (~**15.2.Rel1**, GCC 15.2, newlib/newlib-nano). **Stale correction: NOT Linaro/Launchpad, NOT "GNU Arm Embedded Toolchain."** Distribution migrating to Arm's GitLab. |
| **Arm Toolchain for Embedded (ATfE)** | The **"LLVM Embedded Toolchain for Arm" was renamed ATfE** and folded into `arm/arm-toolchain`. **19.1.5 was the last release under the old name**; ATfE for LLVM 20+ (~22.x). Stack: clang/clang++, lld, compiler-rt, picolibc. Better Armv8-M + Helium/MVE codegen. |
| **zig cc** (Zig **0.16.0**) | Drop-in clang-compatible C/C++ cross-compiler; ~97 libc targets, per-glibc pinning (`-target aarch64-linux-gnu.2.28`). **1.0 has NOT happened** — models often think 0.13/0.14. Backs cargo-zigbuild + Go CGO. |
| crosstool-ng 1.28.0 (2025-09-06) | Build fully custom libc/arch cross toolchains from source when no prebuilt covers the combo. |
| kernel.org crosstools | GPG-signed, **kernel-build-only — no libc, cannot build userspace**. |

- **CMake toolchain file** is the sysroot-discipline mechanism: `-DCMAKE_TOOLCHAIN_FILE=...`. Bare metal → `CMAKE_SYSTEM_NAME Generic` + `CMAKE_TRY_COMPILE_TARGET_TYPE STATIC_LIBRARY` (the compiler probe otherwise tries to link an executable that can't link freestanding). Linux cross → `CMAKE_SYSROOT`, `CMAKE_FIND_ROOT_PATH*`.
- **Distro build systems:** Yocto current LTS **6.0 "Wrynose"** (April 2026, Linux 6.18, LTS to April 2030) — **NOT Scarthgap** (superseded May 2026). Buildroot latest stable 2026.02.x; **LTS 2025.02 now 3-year support** (extended from 1 year in 2026).

## Emulation & host-vs-target testing

- **QEMU 10.2.0** (Dec 2025 — on 10.x, not 9.x). Two modes, very different validity:
  - **`qemu-user` + `binfmt_misc`** — runs cross-compiled **Linux userspace** binaries on x86_64 (basis of multi-arch container builds). **Linux syscalls only — no MMIO, no peripherals, no interrupts. NEVER valid as firmware validation.**
  - **`qemu-system-*`** full-system — a *few* MCU machine models (`lm3s6965evb`, `mps2-an385`, `microbit`) with **minimal peripheral fidelity** — fine for no_std unit tests on a virtual Cortex-M in CI, not for modeling your real board.
- **Renode 1.16.1** (Antmicro, ~2026-02-16) — purpose-built for **MCU-class + multi-node** emulation with real **peripheral + interconnect modeling**, deterministic virtual time; ships `renode-test-action`. **2026 guidance: Renode for MCU simulation, QEMU for full-system Linux.**
- **Test pyramid:** (1) pure logic → host `cargo test` (builds for host by default — a firmware crate's green `cargo test` may only be testing host-compiled logic; be explicit); (2) arch-sensitive userspace → qemu-user; (3) no_std integration → qemu-system runner or Renode; (4) peripheral/timing → Renode; (5) acceptance → real hardware via probe-rs/embedded-test **(gated by user confirmation)**. Keep hardware code behind embedded-hal traits so the bulk tests on host with `embedded-hal-mock`. HIL CI = self-hosted runners wired to boards; LAVA for large farms; Zephyr Twister orchestrates native_sim/QEMU/Renode/real board.

## ROS 2 / DDS / micro-XRCE-DDS (training data is most stale here)

### Distro landscape [settled, verified directly]
| Distro | Released | LTS? | Ubuntu | EOL |
|---|---|---|---|---|
| **Lyrical Luth** | **2026-05-22** | **LTS** | 26.04 Resolute | May 2031 — **current newest** |
| Kilted Kaiju | May 2025 | non-LTS | 24.04 | ~late 2026 — first with Zenoh Tier 1 rmw |
| Jazzy Jalisco | May 2024 | LTS | 24.04 | May 2029 — widely deployed in field |
| Humble Hawksbill | 2022 | LTS | 22.04 | May 2027 |

Cadence: even-year May = LTS (5 yr), odd-year = non-LTS (1.5 yr). A draft still calling Jazzy "the current LTS" or "next LTS lands 2026 May" is out of date.

### rmw default & Zenoh [settled facts; separate from hype]
- **Default rmw is still `rmw_fastrtps_cpp` (Fast DDS)** across Jazzy, Kilted, **and Lyrical** — no switch. Cyclone DDS + RTI Connext remain alternatives (`RMW_IMPLEMENTATION=...`).
- **Zenoh — biggest delta vs training data:** Zenoh is **not DDS** (distinct data-centric pub/sub protocol). **`rmw_zenoh_cpp` is Tier 1 since Kilted (May 2025)**, continues Tier 1 in Lyrical/Rolling, in core (REP-2005) with full SROS2. A model may still think it's experimental — **it is Tier 1. BUT not the default, no committed plan to make it default.** Needs a **router (`zenohd`)** reachable for discovery, vs DDS peer-to-peer. Embedded: **`zenoh-pico`** (native C) for Zephyr/ESP32/FreeRTOS.

### Fast DDS (eProsima) — hard 2.x→3.x break [settled]
- **On 3.x, latest v3.6.2** (3.6.x LTS line). **3.0.0 (~Aug 2024) was a hard, non-backwards-compatible major break** — the biggest trap here. Migration essentials:
  - Headers **`include/fastrtps/` → `include/fastdds/`**; CMake target **`fastrtps` → `fastdds`**.
  - Namespaces: built-in topic data types → `eprosima::fastdds::rtps::`; `Duration_t`/`Time_t` → `eprosima::fastdds::dds`.
  - Renames: `DiscoveryProtocol_t` → `DiscoveryProtocol`; camelCase QoS → snake_case (`heartbeatPeriod` → `heartbeat_period`). All `FASTDDS_DEPRECATED` APIs removed.
  - **Fast-DDS-Gen on 4.x** (IDL→TypeSupport; now generates RPC/service code).

### Micro-XRCE-DDS / micro-ROS (MCU side) [settled architecture; version cliff]
- **Architecture:** the **Client** runs on the resource-constrained MCU; the **Agent** runs on a companion host and bridges the client into the full DDS graph (the Agent is the actual DDS participant). micro-ROS wraps this: `micro_ros_agent` (ROS 2 node) + firmware client via `micro_ros_setup`.
- **Versions:** **Agent v3.0.1 / Client 3.0.x.** **v3.0.0 bumped internal Fast DDS to 3.x and is NOT compatible with Client < 3.0.0 — a version cliff.** Distro-aligned branches exist (mismatched Fast-CDR is a known build-break). Supports Humble/Jazzy/Kilted/Rolling (Lyrical emerging). Targets: FreeRTOS, Zephyr, NuttX, ESP-IDF, bare-metal. **PX4 uses the uXRCE-DDS bridge** as its ROS 2 interface.
- **Quirks:** Agent must be up/reachable or the Client blocks (single point of failure); reliable streams have a **bounded history buffer** (publish faster than it drains → drop/block); MCU static memory caps message size/in-flight count (fit the MTU or fragment); serial is framing-sensitive — agent baud (`-b`) must match, silent stalls come from MTU/baud/reliability mismatch. Shared-memory transport is Agent↔ROS 2 only, **not** on the MCU link.

## Key sources
- Rust platform tiers: doc.rust-lang.org/beta/rustc/platform-support.html ; build-std goals: blog.rust-lang.org/2026/05/18/project-goals-2026-04/
- embedded-hal 1.0: blog.rust-embedded.org/embedded-hal-v1/ ; probe-run deprecation: ferrous-systems.com/blog/probe-run-deprecation/
- probe-rs: github.com/probe-rs/probe-rs ; defmt 1.0: ferrous-systems.com/blog/defmt-1-0/ ; Embassy: embassy.dev ; esp-hal 1.0: developer.espressif.com/blog/2025/10/esp-hal-1/
- cross: github.com/cross-rs/cross/releases ; cargo-zigbuild: github.com/rust-cross/cargo-zigbuild ; musl lint: github.com/rust-lang/rust/pull/144513
- Arm GNU Toolchain: developer.arm.com/downloads ; ATfE: github.com/arm/arm-toolchain ; Zig 0.16: ziglang.org/download/0.16.0/release-notes.html
- QEMU 10.2: qemu.org/2025/12/24/qemu-10-2-0/ ; Renode: github.com/renode/renode/releases ; Yocto: yoctoproject.org/development/releases/
- ROS 2 Lyrical: docs.ros.org/en/lyrical/ ; ROS 2 EOL: endoflife.date/ros-2 ; rmw_zenoh Tier 1: github.com/ros2/rmw_zenoh
- Fast DDS: github.com/eProsima/Fast-DDS/releases + migration_guide ; Micro-XRCE-DDS Agent: github.com/eProsima/Micro-XRCE-DDS-Agent/releases ; PX4: docs.px4.io/main/en/middleware/uxrce_dds.html
