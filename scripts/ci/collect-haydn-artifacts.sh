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
: "${DT_IMAGE_PAGE_SIZE:=4096}"

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

create_dt_image() {
	local output="$1"
	shift

	if [ "$#" -eq 0 ]; then
		return
	fi

	python3 - "${output}" "${DT_IMAGE_PAGE_SIZE}" "$@" <<'PY'
import os
import struct
import sys

output = sys.argv[1]
page_size = int(sys.argv[2])
inputs = sys.argv[3:]

magic = 0xD7B7AB1E
header_size = struct.calcsize(">8I")
entry_size = struct.calcsize(">8I")
entries_offset = header_size
payload_offset = header_size + entry_size * len(inputs)
entries = []
payloads = []

for path in inputs:
    with open(path, "rb") as image:
        payload = image.read()
    entries.append((len(payload), payload_offset, 0, 0, 0, 0, 0, 0))
    payloads.append(payload)
    payload_offset += len(payload)

os.makedirs(os.path.dirname(output), exist_ok=True)
with open(output, "wb") as image:
    image.write(struct.pack(
        ">8I",
        magic,
        payload_offset,
        header_size,
        entry_size,
        len(inputs),
        entries_offset,
        page_size,
        0,
    ))
    for entry in entries:
        image.write(struct.pack(">8I", *entry))
    for payload in payloads:
        image.write(payload)
PY

	log "created ${output} from $# device tree file(s)"
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
	dtb_inputs=()
	dtbo_inputs=()
	while IFS= read -r dts_artifact; do
		rel="${dts_artifact#${boot_dir}/}"
		copy_if_present "${dts_artifact}" "${ARTIFACT_DIR}/${rel}"
		case "${dts_artifact}" in
			*.dtb)
				dtb_inputs+=("${dts_artifact}")
				;;
			*.dtbo)
				dtbo_inputs+=("${dts_artifact}")
				;;
		esac
	done < <(
		find "${boot_dir}/dts" -type f \( \
			-name '*haydn*.dtb' -o \
			-name '*haydn*.dtbo' -o \
			-name '*lahaina*.dtb' -o \
			-name '*lahaina*.dtbo' \
		\) | sort
	)

	if [ ! -f "${ARTIFACT_DIR}/dtb.img" ] && [ "${#dtb_inputs[@]}" -gt 0 ]; then
		create_dt_image "${ARTIFACT_DIR}/dtb.img" "${dtb_inputs[@]}"
	fi
	if [ ! -f "${ARTIFACT_DIR}/dtbo.img" ] && [ "${#dtbo_inputs[@]}" -gt 0 ]; then
		create_dt_image "${ARTIFACT_DIR}/dtbo.img" "${dtbo_inputs[@]}"
	fi
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
