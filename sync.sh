#!/bin/bash
# repo sync with retries (rate limits)
cd "$(dirname "$0")/src"
for i in $(seq 1 15); do
  repo sync -c -j8 --force-sync --no-clone-bundle --no-tags --optimized-fetch && { echo SYNC-OK; exit 0; }
  echo "sync attempt $i failed, retrying in 60s"; sleep 60
done
echo SYNC-FAILED; exit 1
