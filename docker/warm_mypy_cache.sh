#!/bin/bash
# Invoked as [bash warm_mypy_cache.sh], and that ignores the shebang line, so
# the shell options have to be set here to have any effect.
set -Eeu -o pipefail

# Warms mypy's cache. Most of what mypy does on a kata is not looking at the
# kata: it analyses typeshed's stubs for the standard library, and that work is
# identical on every test-run and has nothing to do with what a learner wrote.
# A kata runs in a container thrown away afterwards, so a cache built during the
# run is of no use to the next one.
#
# The cache is world-writable because a kata runs as the sandbox user and mypy
# adds to the cache as the learner's own files change. The container is thrown
# away afterwards, so nothing outlives the run.

readonly CACHE_DIR=/mypy-cache
readonly WORK_DIR=/tmp/warm_mypy

mkdir -p "${CACHE_DIR}" "${WORK_DIR}" && cd "${WORK_DIR}"

# The start-point's own file, so the stubs pulled in are the ones a kata pulls
# in. cyber-dojo.sh runs [mypy *.py], which reaches hiker.py and not the step
# definitions under steps/, so the step definitions are left out here too.
cat > hiker.py << 'EOF'
class Hiker:

    def answer(self: Hiker, first: int, second: int) -> int:
        return first * second
EOF

MYPY_CACHE_DIR="${CACHE_DIR}" mypy hiker.py

chmod -R 777 "${CACHE_DIR}"
du -sm "${CACHE_DIR}"

# A cache is keyed on the mypy version and the flags that filled it. If those
# ever drift from what cyber-dojo.sh runs, mypy silently reanalyses and the
# test-run is merely as slow as it was before. This compares a run against the
# warmed cache with one against an empty one, and insists the warm run be
# clearly quicker. A cache that is not being hit scores about 1.
#
# The comparison is against a cold run rather than a fixed number of seconds
# because this same script runs under QEMU when the arm64 half of the image is
# built on an amd64 machine. Emulated, a warm run takes far longer than it does
# natively, so any threshold that fits one fails the other. A ratio holds either
# way: both runs are slowed by the same emulation. It does shrink under
# emulation, because mypy's startup costs the same whatever the cache holds and
# emulation inflates it, so the bar is set well below what a native run scores.
#
# The source is edited first, so the warm run is measured the way a kata meets
# it, with the learner's file changed and only the stubs still cached.
sed -i 's/first \* second/second * first/' hiker.py

mypy_seconds()
{
  local -r cache_dir="${1}"
  { TIMEFORMAT='%3R'; time MYPY_CACHE_DIR="${cache_dir}" mypy hiker.py > /dev/null 2>&1; } 2>&1
}

readonly COLD_SECONDS=$(mypy_seconds /tmp/cold-mypy-cache)
readonly WARM_SECONDS=$(mypy_seconds "${CACHE_DIR}")
echo "[mypy] cold ${COLD_SECONDS}s, warm ${WARM_SECONDS}s"
rm -rf /tmp/cold-mypy-cache

if ! awk "BEGIN { exit !(${COLD_SECONDS} > ${WARM_SECONDS} * 1.5) }"; then
  >&2 echo "Expected a warmed cache to be clearly quicker than an empty one."
  >&2 echo "The cache is not being hit, so a kata's test-run will reanalyse the stubs."
  exit 42
fi

# The timing runs above wrote as root; a kata runs as sandbox.
chmod -R 777 "${CACHE_DIR}"

cd /
rm -rf "${WORK_DIR}"
