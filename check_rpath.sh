#!/bin/bash

# Checks RUNPATH on all .so.4.11.0 files across all lib dirs found in the repo.
# Read-only — makes no changes.

PASS=0
FAIL=0
WARN=0

check_dir() {
    local dir="$1"
    local label="$2"

    if [ ! -d "$dir" ]; then
        echo "  [SKIP] $dir not found"
        return
    fi

    local found=0
    while IFS= read -r -d $'\0' f; do
        found=1
        local name
        name=$(basename "$f")
        local rpath
        rpath=$(readelf -d "$f" 2>/dev/null | grep RUNPATH | awk '{print $NF}')

        if [ -z "$rpath" ]; then
            echo "  [OK]   $label/$name: [none]"
            PASS=$((PASS + 1))
        elif [ "$rpath" = '[$ORIGIN]' ]; then
            echo "  [OK]   $label/$name: \$ORIGIN"
            PASS=$((PASS + 1))
        elif echo "$rpath" | grep -qE '^(\[::+\]|\[:+\])$'; then
            echo "  [WARN] $label/$name: garbled RUNPATH $rpath"
            WARN=$((WARN + 1))
        else
            echo "  [BAD]  $label/$name: $rpath"
            FAIL=$((FAIL + 1))
        fi
    done < <(find "$dir" -maxdepth 1 -name "*.so.*.*.*" -type f -print0 | sort -z)

    if [ "$found" -eq 0 ]; then
        echo "  [SKIP] no *.so.4.11.0 files in $dir"
    fi
}

CURRENT_BRANCH=$(git rev-parse --abbrev-ref HEAD)
echo ""
echo "=== Branch: $CURRENT_BRANCH ==="

for libdir in */lib; do
    [ -d "$libdir" ] || continue
    arch="${libdir%/lib}"
    check_dir "$libdir" "$arch"
done

echo ""
echo "=== Summary ==="
echo "  OK:   $PASS"
echo "  WARN: $WARN  (garbled — needs fix)"
echo "  BAD:  $FAIL  (hardcoded path — needs fix)"

if [ "$FAIL" -gt 0 ] || [ "$WARN" -gt 0 ]; then
    exit 1
fi
