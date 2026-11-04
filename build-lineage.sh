#!/bin/bash
#
# Build LineageOS 24.0 for the Samsung Galaxy S8+ (dream2lte).
#
#   ./build-lineage.sh            m bacon (images + flashable zip)
#   ./build-lineage.sh -j8        extra args are passed to m
#
# Safe to stop and rerun; it resumes. Log: src/out/build-lineage.log
# Output: src/out/target/product/dream2lte/lineage-24.0-*-UNOFFICIAL-dream2lte.zip

set -euo pipefail
cd "$(dirname "$(readlink -f "$0")")/src"
mkdir -p out
LOG=out/build-lineage.log

source build/envsetup.sh >/dev/null
lunch lineage_dream2lte-cp2a-userdebug >/dev/null

echo "Build started $(date), log: $LOG"
m bacon "$@" 2>&1 | tee "$LOG"
echo "Build finished $(date)" | tee -a "$LOG"
