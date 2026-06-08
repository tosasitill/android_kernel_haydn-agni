# Haydn 5.10 Docker/Actions bring-up

This branch starts from the CodeLinaro `KERNEL.PLATFORM.1.0.c27` msm-5.10
baseline. The first compile target is a reproducible arm64 GKI `Image`; Haydn
device trees, vendor modules, dtb/dtbo packaging, and AnyKernel packaging are
added only after the base 5.10 build is stable.

## Build policy

- macOS checkout: code reading, diffs, commits, log analysis, and pushes only.
- Local compile iteration: allowed only inside Docker on a Linux filesystem.
- GitHub Actions: canonical verification and downloadable artifacts.
- Do not run `make`, `build_kernel_haydn.sh`, or other kernel build commands
  directly from the macOS checkout.

## Workflow inputs

Use `.github/workflows/build-haydn-kernel.yml`.

- `toolchain`: `cpullvm` by default; `system-clang` is available for comparison.
- `defconfig`: defaults to `gki_defconfig` for the initial 5.10 baseline.
- `build_targets`: defaults to `Image`.
- `disable_lto_cfi`: defaults to `true` because full LTO OOMs on the current
  Docker Desktop memory limit and is slow for early bring-up.

The workflow uploads raw artifacts, `.config`, `System.map`, logs, and any
matched dtb/dtbo/modules when those targets exist.

## Current status

The CodeLinaro 5.10.136 baseline compiles `gki_defconfig` + `Image` in Docker
when LTO/CFI are disabled after defconfig generation:

```sh
make O=/out LLVM=1 LLVM_IAS=1 HOSTCC=gcc HOSTCXX=g++ gki_defconfig
scripts/config --file /out/.config -d LTO -d LTO_CLANG -d LTO_CLANG_FULL \
  -d LTO_CLANG_THIN -e LTO_NONE -d CFI_CLANG -d CFI_CLANG_SHADOW
make O=/out LLVM=1 LLVM_IAS=1 HOSTCC=gcc HOSTCXX=g++ olddefconfig
