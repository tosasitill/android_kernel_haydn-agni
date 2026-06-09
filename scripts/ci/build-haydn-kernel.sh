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
: "${DEFCONFIG:=haydn_gki_defconfig}"
: "${OUT_DIR:=/out}"
: "${CCACHE_DIR:=/ccache}"
: "${MAKE_JOBS:=$(nproc)}"
: "${BUILD_TARGETS:=Image dtbs modules}"
: "${VENDOR_CONFIG:=vendor/haydn_GKI.config}"
: "${DISABLE_KSYMS_TRIM:=1}"
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

if [ -n "${VENDOR_CONFIG}" ]; then
	if [ ! -f "arch/arm64/configs/${VENDOR_CONFIG}" ]; then
		die "missing arm64 vendor config: arch/arm64/configs/${VENDOR_CONFIG}"
	fi
elif [ "${BUILD_TARGETS//modules/}" != "${BUILD_TARGETS}" ]; then
	log "module build requested without a vendor config fragment"
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

extra_kcflags=()
warning_probe="${OUT_DIR}/.warning-probe.o"
for warning in \
	default-const-init-var-unsafe \
	default-const-init-field-unsafe \
	uninitialized-const-pointer
do
	if printf '' | clang \
		-Werror \
		-Wunknown-warning-option \
		"-Wno-${warning}" \
		-x c -c -o "${warning_probe}" - >/dev/null 2>&1; then
		extra_kcflags+=("-Wno-${warning}")
	fi
done
rm -f "${warning_probe}"

log "kernel version: ${version:-unknown}"
log "toolchain: ${TOOLCHAIN}"
log "defconfig: ${DEFCONFIG}"
log "out dir: ${OUT_DIR}"
log "build targets: ${BUILD_TARGETS}"
log "vendor config: ${VENDOR_CONFIG:-<none>}"
log "disable ksym trimming: ${DISABLE_KSYMS_TRIM}"
log "disable LTO/CFI: ${DISABLE_LTO_CFI}"
log "extra KCFLAGS: ${extra_kcflags[*]:-<none>}"

make_args=(
	O="${OUT_DIR}"
	LLVM=1
	LLVM_IAS=1
	HOSTCC=gcc
	HOSTCXX=g++
)
if [ "${#extra_kcflags[@]}" -gt 0 ]; then
	make_args+=("KCFLAGS=${extra_kcflags[*]}")
fi

{
	printf 'GITHUB_SHA=%s\n' "${GITHUB_SHA:-unknown}"
	printf 'GITHUB_REF=%s\n' "${GITHUB_REF:-unknown}"
	printf 'KERNEL_VERSION=%s\n' "${version:-unknown}"
	printf 'TOOLCHAIN=%s\n' "${TOOLCHAIN}"
	printf 'DEFCONFIG=%s\n' "${DEFCONFIG}"
	printf 'BUILD_TARGETS=%s\n' "${BUILD_TARGETS}"
	printf 'VENDOR_CONFIG=%s\n' "${VENDOR_CONFIG:-<none>}"
	printf 'DISABLE_KSYMS_TRIM=%s\n' "${DISABLE_KSYMS_TRIM}"
	printf 'DISABLE_LTO_CFI=%s\n' "${DISABLE_LTO_CFI}"
	printf 'KCFLAGS=%s\n' "${extra_kcflags[*]:-<none>}"
} > "${OUT_DIR}/build-metadata.txt"

log "running defconfig"
make -j"${MAKE_JOBS}" "${make_args[@]}" "${DEFCONFIG}" 2>&1 | tee "${OUT_DIR}/defconfig.log"

if [ -n "${VENDOR_CONFIG}" ]; then
	log "merging vendor config: ${VENDOR_CONFIG}"
	scripts/kconfig/merge_config.sh \
		-m \
		-O "${OUT_DIR}" \
		"${OUT_DIR}/.config" \
		"arch/arm64/configs/${VENDOR_CONFIG}" 2>&1 | tee -a "${OUT_DIR}/defconfig.log"
	make -j"${MAKE_JOBS}" "${make_args[@]}" olddefconfig 2>&1 | tee -a "${OUT_DIR}/defconfig.log"
fi

log "selected hardware stack config"
grep -E 'CONFIG_(DISPLAY_BUILD|DRM_MSM|DRM_MSM_SDE|DRM_MSM_DSI|DRM_MSM_DP|DRM_SDE_WB|DRM_SDE_RSC|QCOM_MDSS_PLL|DSI_PARSER|SPECTRA_CAMERA|QCA_CLD_WLAN|CNSS2|CNSS_QCA6490|SND_SOC_CS35L41|TOUCHSCREEN_(FTS|FOCALTECH|SYNAPTICS_DSX))=' "${OUT_DIR}/.config" | sort | tee -a "${OUT_DIR}/defconfig.log" || true

log "restricting SoC target to Lahaina/Haydn bring-up"
scripts/config --file "${OUT_DIR}/.config" \
	-e ARCH_LAHAINA \
	-d ARCH_SHIMA
make -j"${MAKE_JOBS}" "${make_args[@]}" olddefconfig 2>&1 | tee -a "${OUT_DIR}/defconfig.log"
grep -E 'CONFIG_ARCH_(LAHAINA|SHIMA)' "${OUT_DIR}/.config" | sort | tee -a "${OUT_DIR}/defconfig.log" || true

case "${DISABLE_KSYMS_TRIM}" in
	1|true|TRUE|yes|YES)
		log "disabling exported symbol trimming for bring-up"
		scripts/config --file "${OUT_DIR}/.config" \
			-d TRIM_UNUSED_KSYMS \
			-d UNUSED_KSYMS_WHITELIST_ONLY \
			--set-str UNUSED_KSYMS_WHITELIST ""
		make -j"${MAKE_JOBS}" "${make_args[@]}" olddefconfig 2>&1 | tee -a "${OUT_DIR}/defconfig.log"
		grep -E 'CONFIG_(TRIM_UNUSED_KSYMS|UNUSED_KSYMS_WHITELIST)' "${OUT_DIR}/.config" | sort | tee -a "${OUT_DIR}/defconfig.log" || true
		;;
esac

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
