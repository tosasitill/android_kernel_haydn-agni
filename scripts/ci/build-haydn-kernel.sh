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
	die "kernel builds must run in GitHub Actions or an explicit Docker bring-up shell"
fi

if [ ! -f Makefile ] || [ ! -d arch/arm64 ]; then
	die "run this script from the kernel source root"
fi

: "${TOOLCHAIN:=cpullvm}"
: "${DEFCONFIG:=gki_defconfig}"
: "${OUT_DIR:=/out}"
: "${CCACHE_DIR:=/ccache}"
: "${MAKE_JOBS:=$(nproc)}"
: "${BUILD_TARGETS:=Image}"
: "${DISABLE_LTO_CFI:=1}"

mkdir -p "${OUT_DIR}" "${CCACHE_DIR}"

export ARCH=arm64
export SUBARCH=arm64
export CCACHE_DIR
export CROSS_COMPILE_COMPAT="${CROSS_COMPILE_COMPAT:-arm-linux-gnueabi-}"

case "${TOOLCHAIN}" in
	cpullvm)
		if [ -z "${CPULLVM_BIN:-}" ] || [ ! -x "${CPULLVM_BIN}/clang" ]; then
			die "missing CPULLVM clang at ${CPULLVM_BIN:-<unset>}/clang"
		fi
		export PATH="${CPULLVM_BIN}:${PATH}"
		;;
	system-clang)
		;;
	*)
		die "unknown toolchain: ${TOOLCHAIN}"
		;;
esac

if [ ! -f "arch/arm64/configs/${DEFCONFIG}" ]; then
	die "missing arm64 defconfig: arch/arm64/configs/${DEFCONFIG}"
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

clang --version
ld.lld --version || true

log "kernel version: ${version:-unknown}"
log "toolchain: ${TOOLCHAIN}"
log "defconfig: ${DEFCONFIG}"
log "out dir: ${OUT_DIR}"
log "build targets: ${BUILD_TARGETS}"
log "disable LTO/CFI: ${DISABLE_LTO_CFI}"

make_args=(
	O="${OUT_DIR}"
	LLVM=1
	LLVM_IAS=1
	HOSTCC=gcc
	HOSTCXX=g++
)

{
	printf 'GITHUB_SHA=%s\n' "${GITHUB_SHA:-unknown}"
	printf 'GITHUB_REF=%s\n' "${GITHUB_REF:-unknown}"
	printf 'KERNEL_VERSION=%s\n' "${version:-unknown}"
	printf 'TOOLCHAIN=%s\n' "${TOOLCHAIN}"
	printf 'DEFCONFIG=%s\n' "${DEFCONFIG}"
	printf 'BUILD_TARGETS=%s\n' "${BUILD_TARGETS}"
	printf 'DISABLE_LTO_CFI=%s\n' "${DISABLE_LTO_CFI}"
} > "${OUT_DIR}/build-metadata.txt"

log "running defconfig"
make -j"${MAKE_JOBS}" "${make_args[@]}" "${DEFCONFIG}" 2>&1 | tee "${OUT_DIR}/defconfig.log"

case "${DISABLE_LTO_CFI}" in
	1|true|TRUE|yes|YES)
		log "disabling LTO/CFI for bring-up"
		scripts/config --file "${OUT_DIR}/.config" \
			-d LTO \
			-d LTO_CLANG \
			-d LTO_CLANG_FULL \
			-d LTO_CLANG_THIN \
			-e LTO_NONE \
			-d CFI_CLANG \
			-d CFI_CLANG_SHADOW
		make -j"${MAKE_JOBS}" "${make_args[@]}" olddefconfig 2>&1 | tee -a "${OUT_DIR}/defconfig.log"
		grep -E 'CONFIG_(LTO|CFI)' "${OUT_DIR}/.config" | sort | tee -a "${OUT_DIR}/defconfig.log" || true
		;;
esac

log "running kernel build"
# shellcheck disable=SC2206
targets=(${BUILD_TARGETS})
make -j"${MAKE_JOBS}" "${make_args[@]}" "${targets[@]}" 2>&1 | tee "${OUT_DIR}/build.log"
