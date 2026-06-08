# Haydn 5.10 CI-only migration

This migration branch treats kernel builds as GitHub Actions only. Do not run
local `make`, `build_kernel_haydn.sh`, or `build_kernel_haydn_90hz.sh` while
bringing up the 5.10 tree.

## Workflow

Use `.github/workflows/build-haydn-kernel.yml` for every compile attempt.

- `mode`: `normal` or `hz90`.
- `toolchain`: `cpullvm` by default, `system-clang` for comparison only.
- `defconfig`: defaults to `agni_haydn_defconfig`.
- `build_targets`: optional make targets for 5.10 bring-up, for example
  `Image dtbs modules`.
- `use_llvm_shorthand`: passes `LLVM=1` in addition to the explicit LLVM tools.

The workflow uploads:

- raw kernel artifacts such as `Image`, `dtb.img`, `dtbo.img`, matched
  Haydn/Lahaina dtb/dtbo files, modules, config, `System.map`, and logs;
- an AnyKernel zip when `anykernel3/` and `Image` are present;
- `defconfig.log`, `build.log`, and `build-metadata.txt` even on failure.

## Local guard

`scripts/ci/build-haydn-kernel.sh` exits outside GitHub Actions unless
`ALLOW_LOCAL_KERNEL_BUILD=1` is set. Keep that override unused for this branch;
it exists only so the script can be diagnosed deliberately if needed.

## Bring-up loop

1. Push a 5.10 migration commit to the branch.
2. Let GitHub Actions compile it.
3. Use the uploaded logs to fix the next Kconfig, header, API, DTS, module, or
   packaging failure.
4. Repeat until Actions produces `Image`, dtb/dtbo artifacts, modules, and a
   flashable AnyKernel zip.
