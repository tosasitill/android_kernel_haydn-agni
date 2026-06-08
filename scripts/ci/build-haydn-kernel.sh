#!/usr/bin/env bash
# SPDX-License-Identifier: GPL-2.0

set -Eeuo pipefail

log() {
	printf '[haydn-ci] %s\n' "$*"
}

die() {
	printf '[haydn-ci] error: %s\n' "$*" >&2
	exit 1
}

if [ "${GITHUB_ACTIONS:-}" != "true" ] && [ "${ALLOW_LOCAL_KERNEL_BUILD:-}" != "1" ]; then
	die "kernel builds are CI-only for this migration; run through GitHub Actions"
fi

if [ ! -f Makefile ] || [ ! -d arch/arm64 ]; then
	die "run this script from the kernel source root"
fi

: "${MODE:=normal}"
: "${TOOLCHAIN:=cpullvm}"
: "${DEFCONFIG:=agni_haydn_defconfig}"
: "${OUT_DIR:=/out}"
: "${CCACHE_DIR:=/ccache}"
: "${MAKE_JOBS:=$(nproc)}"
: "${BUILD_TARGETS:=}"
: "${USE_LLVM_SHORTHAND:=0}"
: "${HZ90_DTS_PATH:=arch/arm64/boot/dts/vendor/qcom/display/lahaina-sde-display.dtsi}"

mkdir -p "${OUT_DIR}" "${CCACHE_DIR}"

export ARCH=arm64
export SUBARCH=arm64
export CCACHE_DIR
export CCACHE_BASEDIR="${CCACHE_BASEDIR:-$(pwd)}"
export CCACHE_NOHASHDIR="${CCACHE_NOHASHDIR:-1}"
export CROSS_COMPILE_COMPAT="${CROSS_COMPILE_COMPAT:-arm-linux-gnueabi-}"

if [ "${TOOLCHAIN}" = "cpullvm" ]; then
	if [ -z "${CPULLVM_BIN:-}" ] || [ ! -x "${CPULLVM_BIN}/clang" ]; then
		die "missing CPULLVM clang at ${CPULLVM_BIN:-<unset>}/clang"
	fi
	export PATH="${CPULLVM_BIN}:${PATH}"
elif [ "${TOOLCHAIN}" != "system-clang" ]; then
	die "unknown toolchain: ${TOOLCHAIN}"
fi

if [ ! -f "arch/arm64/configs/${DEFCONFIG}" ]; then
	die "missing arm64 defconfig: arch/arm64/configs/${DEFCONFIG}"
fi

clang --version
ld.lld --version || true

if [ "${MODE}" = "hz90" ]; then
	if [ ! -f "${HZ90_DTS_PATH}" ]; then
		die "missing 90Hz target DTS file: ${HZ90_DTS_PATH}"
	fi
	if ! grep -q '/delete-node/ timing@1' "${HZ90_DTS_PATH}"; then
		die "90Hz DTS marker not found in ${HZ90_DTS_PATH}"
	fi
	sed -i 's|/delete-node/ timing@1|/delete-node/ timing@2|' "${HZ90_DTS_PATH}"
elif [ "${MODE}" != "normal" ]; then
	die "unknown build mode: ${MODE}"
fi

version="$(awk '
	/^VERSION =/ { version = $3 }
	/^PATCHLEVEL =/ { patchlevel = $3 }
	/^SUBLEVEL =/ { sublevel = $3 }
	END {
		if (version && patchlevel) {
			printf "%s.%s", version, patchlevel
			if (sublevel) {
				printf ".%s", sublevel
			}
			printf "\n"
		}
	}
' Makefile)"

log "kernel version: ${version:-unknown}"
log "mode: ${MODE}"
log "toolchain: ${TOOLCHAIN}"
log "defconfig: ${DEFCONFIG}"
log "out dir: ${OUT_DIR}"
log "build targets: ${BUILD_TARGETS:-<default>}"

make_args=(
	O="${OUT_DIR}"
	LLVM_IAS=1
	DISABLE_WRAPPER=1
	HOSTCC=gcc
	HOSTCXX=g++
	"REAL_CC=ccache clang"
	LD=ld.lld
	LD_COMPAT=ld.lld
	AR=llvm-ar
	NM=llvm-nm
	OBJCOPY=llvm-objcopy
	OBJDUMP=llvm-objdump
	READELF=llvm-readelf
	OBJSIZE=llvm-size
	STRIP=llvm-strip
)

if [ "${USE_LLVM_SHORTHAND}" = "1" ]; then
	make_args+=(LLVM=1)
fi

{
	printf 'GITHUB_SHA=%s\n' "${GITHUB_SHA:-unknown}"
	printf 'GITHUB_REF=%s\n' "${GITHUB_REF:-unknown}"
	printf 'KERNEL_VERSION=%s\n' "${version:-unknown}"
	printf 'MODE=%s\n' "${MODE}"
	printf 'TOOLCHAIN=%s\n' "${TOOLCHAIN}"
	printf 'DEFCONFIG=%s\n' "${DEFCONFIG}"
	printf 'BUILD_TARGETS=%s\n' "${BUILD_TARGETS:-<default>}"
	printf 'USE_LLVM_SHORTHAND=%s\n' "${USE_LLVM_SHORTHAND}"
} > "${OUT_DIR}/build-metadata.txt"

log "running defconfig"
make -j"${MAKE_JOBS}" "${make_args[@]}" "${DEFCONFIG}" 2>&1 | tee "${OUT_DIR}/defconfig.log"

log "running kernel build"
if [ -n "${BUILD_TARGETS}" ]; then
	# shellcheck disable=SC2206
	targets=(${BUILD_TARGETS})
	make -j"${MAKE_JOBS}" "${make_args[@]}" "${targets[@]}" 2>&1 | tee "${OUT_DIR}/build.log"
else
	make -j"${MAKE_JOBS}" "${make_args[@]}" 2>&1 | tee "${OUT_DIR}/build.log"
fi
