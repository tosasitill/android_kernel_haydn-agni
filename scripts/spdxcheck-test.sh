#!/bin/sh

PYTHON=${PYTHON:-python3}
command -v "$PYTHON" >/dev/null 2>&1 || {
	echo "$PYTHON not found" >&2
	exit 1
}

# run check on a text and a binary file
for FILE in Makefile Documentation/logo.gif; do
	"$PYTHON" scripts/spdxcheck.py "$FILE"
	"$PYTHON" scripts/spdxcheck.py - < "$FILE"
done

# run check on complete tree to catch any other issues
"$PYTHON" scripts/spdxcheck.py > /dev/null
