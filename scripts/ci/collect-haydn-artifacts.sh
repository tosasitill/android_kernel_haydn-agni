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

: "${OUT_DIR:=/out}"
: "${ARTIFACT_DIR:?ARTIFACT_DIR is required}"
: "${TOOLCHAIN:=cpullvm}"

boot_dir="${OUT_DIR}/arch/arm64/boot"
mkdir -p "${ARTIFACT_DIR}"

if [ ! -d "${OUT_DIR}" ]; then
	log "output directory is missing; nothing to collect from ${OUT_DIR}"
	exit 0
fi

copy_if_present() {
	local src="$1"
	local dst="$2"

	if [ -f "${src}" ]; then
		mkdir -p "$(dirname "${dst}")"
		cp "${src}" "${dst}"
		log "collected ${src}"
	fi
}

for image in Image Image.gz Image.gz-dtb Image.lz4 Image.lz4-dtb; do
	copy_if_present "${boot_dir}/${image}" "${ARTIFACT_DIR}/${image}"
done

copy_if_present "${boot_dir}/dtb.img" "${ARTIFACT_DIR}/dtb.img"
copy_if_present "${boot_dir}/dtbo.img" "${ARTIFACT_DIR}/dtbo.img"
copy_if_present "${OUT_DIR}/.config" "${ARTIFACT_DIR}/config"
copy_if_present "${OUT_DIR}/System.map" "${ARTIFACT_DIR}/System.map"
copy_if_present "${OUT_DIR}/defconfig.log" "${ARTIFACT_DIR}/logs/defconfig.log"
copy_if_present "${OUT_DIR}/build.log" "${ARTIFACT_DIR}/logs/build.log"
copy_if_present "${OUT_DIR}/build-metadata.txt" "${ARTIFACT_DIR}/build-metadata.txt"

if [ -d "${boot_dir}/dts" ]; then
	while IFS= read -r dts_artifact; do
		rel="${dts_artifact#${boot_dir}/}"
		copy_if_present "${dts_artifact}" "${ARTIFACT_DIR}/${rel}"
	done < <(
		find "${boot_dir}/dts" -type f \( \
			-name '*haydn*.dtb' -o \
			-name '*haydn*.dtbo' -o \
			-name '*lahaina*.dtb' -o \
			-name '*lahaina*.dtbo' \
		\) | sort
	)
fi

while IFS= read -r module; do
	rel="${module#${OUT_DIR}/}"
	copy_if_present "${module}" "${ARTIFACT_DIR}/modules/${rel}"
done < <(find "${OUT_DIR}" -type f -name '*.ko' | sort)

if ! find "${ARTIFACT_DIR}" -maxdepth 1 -type f -name 'Image*' -print -quit | grep -q .; then
	if [ -f "${OUT_DIR}/build.log" ]; then
		log "kernel image is missing; preserving logs for failure analysis"
	else
		die "no kernel image or build log was collected from ${OUT_DIR}"
	fi
fi

raw_zip="${ARTIFACT_DIR%/}/../${TOOLCHAIN}-raw.zip"
(
	cd "${ARTIFACT_DIR}"
	zip -qr "${raw_zip}" .
)
log "created raw artifact zip: ${raw_zip}"
