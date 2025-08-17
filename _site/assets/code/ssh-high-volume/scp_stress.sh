#!/usr/bin/env bash
# scp_stress.sh — fire parallel SCP uploads in timed batches and record per-batch elapsed time.
# - Requires: bash, awk, xargs (GNU parallel optional)
# - Config:   source ./scp_stress.conf (override via CONFIG_FILE env var)
# - Output:   results/run_YYYYmmdd_HHMMSS/summary_<HOST>.csv with per-batch timings

set -Eeuo pipefail

# -------------------------
# Load configuration
# -------------------------
CONFIG_FILE="${CONFIG_FILE:-./scp_stress.conf}"
if [[ -f "$CONFIG_FILE" ]]; then
  # shellcheck disable=SC1090
  source "$CONFIG_FILE"
else
  echo "[x] Config file not found: $CONFIG_FILE" >&2
  exit 1
fi

# -------------------------
# Usage / help
# -------------------------
usage() {
  cat <<'EOF'
Usage: scp_stress.sh [flags]

Flags override config values:
  -H HOST           Target host
  -U USER           SSH user
  -n N              Total connections / sessions
  -j J              Parallel jobs (per batch)
  -p FILE           Payload file to send (skip generation)
  -S KB             Payload size in KB if generating
  -r DIR            Base results directory
  -t SECONDS        SSH ConnectTimeout
  -o "SSH_OPT ..."  Extra ssh/scp -o options (may repeat)
  --use-parallel    Use GNU parallel (if installed) instead of xargs
  -q                Quiet logging
  -h, --help        Show this help

Examples:
  ./scp_stress.sh -H barrie -U youruser -n 400 -j 40
  CONFIG_FILE=prod.conf ./scp_stress.sh -n 2000 -j 200 -o "StrictHostKeyChecking=no"
EOF
}

# -------------------------
# Logging helpers
# -------------------------
log()  { (( QUIET )) || printf '[*] %s\n' "$*" >&2; }
warn() { printf '[!] %s\n' "$*" >&2; }
die()  { printf '[x] %s\n' "$*" >&2; exit 1; }

# -------------------------
# Parse flags (after sourcing config so flags override it)
# -------------------------
LONGOPTS=$(getopt -o H:U:n:j:p:S:r:t:o:qh --long help,use-parallel -- "$@" ) || { usage; exit 2; }
eval set -- "$LONGOPTS"
while true; do
  case "${1:-}" in
    -H) HOST="$2"; shift 2;;
    -U) USER="$2"; shift 2;;
    -n) TOTAL_CONNECTIONS="$2"; shift 2;;
    -j) JOBS="$2"; shift 2;;
    -p) PAYLOAD_FILE="$2"; shift 2;;
    -S) PAYLOAD_SIZE_KB="$2"; shift 2;;
    -r) RESULTS_BASE_DIR="$2"; shift 2;;
    -t) CONNECT_TIMEOUT="$2"; shift 2;;
    -o) SSH_OPTS+=("$2"); shift 2;;
    --use-parallel) USE_PARALLEL=1; shift;;
    -q) QUIET=1; shift;;
    -h|--help) usage; exit 0;;
    --) shift; break;;
    *) break;;
  esac
done

# -------------------------
# Derived paths
# -------------------------
RUN_ID=$(date +'%Y%m%d_%H%M%S')
RESULT_DIR="${RESULTS_BASE_DIR}/run_${HOST}_${RUN_ID}"
SUMMARY="${RESULT_DIR}/summary_${HOST}.csv"
STATS_FILE="${RESULT_DIR}/stats.txt"

PAYLOAD_PATH="${PAYLOAD_FILE:-${RESULT_DIR}/payload_${PAYLOAD_SIZE_KB}k.bin}"

# -------------------------
# Time (ms) function (exported for subshells)
# -------------------------
now_ms() {
  if date +%s%3N >/dev/null 2>&1; then
    date +%s%3N
  elif command -v python3 >/dev/null 2>&1; then
    python3 - <<'PY'
import time
print(int(time.time()*1000))
PY
  else
    echo $(( $(date +%s) * 1000 ))
  fi
}
export -f now_ms

# -------------------------
# Setup
# -------------------------
setup() {
  mkdir -p "$RESULT_DIR"
  log "Results: $RESULT_DIR"

  # Write summary header once up front
  echo "batch_id,start_session,end_session,elapsed_ms" > "$SUMMARY"

  if [[ -n "${PAYLOAD_FILE}" ]]; then
    [[ -f "$PAYLOAD_FILE" ]] || die "Payload file not found: $PAYLOAD_FILE"
  else
    log "Generating ${PAYLOAD_SIZE_KB}KB payload at $PAYLOAD_PATH"
    head -c "$((PAYLOAD_SIZE_KB*1024))" /dev/urandom > "$PAYLOAD_PATH"
  fi

  log "Pre-flight SSH to ${USER}@${HOST} (timeout ${CONNECT_TIMEOUT}s)…"
  if ! ssh -q -o BatchMode=yes -o ConnectTimeout="${CONNECT_TIMEOUT}" \
        ${SSH_OPTS[@]+"${SSH_OPTS[@]/#/-o }"} \
        "${USER}@${HOST}" true 2>/dev/null; then
    warn "SSH pre-flight failed (BatchMode). Ensure key auth works."
  fi
}

# -------------------------
# Worker (exported for subshells)
# No per-session latency logging; just perform the copy.
# -------------------------
simulate_user() {
  local id="$1"
  scp -q -o BatchMode=yes -o ConnectTimeout="${CONNECT_TIMEOUT}" \
      ${SSH_OPTS[@]+"${SSH_OPTS[@]/#/-o }"} \
      "$PAYLOAD_PATH" \
      "${USER}@${HOST}:/tmp/payload_${id}.bin" 2>/dev/null || true
}
export -f simulate_user

# Export scalars used by the worker (arrays don't export reliably)
export RESULT_DIR USER HOST CONNECT_TIMEOUT PAYLOAD_PATH

# -------------------------
# Batch launcher: run in chunks of $JOBS and time each batch
# -------------------------
run_load() {
  local batch_count=$(( (TOTAL_CONNECTIONS + JOBS - 1) / JOBS ))
  log "Launching ${TOTAL_CONNECTIONS} sessions in ${batch_count} batches of ${JOBS}…"

  local loop=1
  local start_id=1

  while (( start_id <= TOTAL_CONNECTIONS )); do
    local end_id=$(( start_id + JOBS - 1 ))
    (( end_id > TOTAL_CONNECTIONS )) && end_id=$TOTAL_CONNECTIONS

    log "--- Batch $loop: sessions ${start_id}-${end_id} ---"
    local start_batch end_batch elapsed
    start_batch=$(now_ms)

    if (( USE_PARALLEL )) && command -v parallel >/dev/null 2>&1; then
      seq "$start_id" "$end_id" \
        | parallel -j"${JOBS}" --halt soon,fail=1 bash -c 'simulate_user "$@"' _ {}
    else
      seq "$start_id" "$end_id" \
        | xargs -P"$JOBS" -I{} bash -c 'simulate_user "$@"' _ {}
    fi

    end_batch=$(now_ms)
    elapsed=$(( end_batch - start_batch ))
    log "Batch $loop finished in ${elapsed} ms"

    # Append per-batch timing row
    echo "$loop,$start_id,$end_id,$elapsed" >> "$SUMMARY"

    start_id=$(( end_id + 1 ))
    (( loop++ ))
  done
}

# -------------------------
# Aggregate (no-op in batch mode, keep for symmetry)
# -------------------------
aggregate() {
  log "Aggregating results… (batch mode only — nothing to do)"
}

# -------------------------
# Batch-level stats
# -------------------------
stats() {
  log "Computing stats…"
  awk -F',' '
    NR>1 {sum+=$4; n++; if(min==""||$4<min) min=$4; if($4>max) max=$4}
    END {
      if(n>0){
        avg=sum/n
        printf "Batches:              %d\n", n
        printf "Average batch time:   %.2f ms\n", avg
        printf "Min / Max batch time: %d ms / %d ms\n", min, max
      } else {
        printf "No batch rows found.\n"
      }
    }
  ' "$SUMMARY" | tee "$STATS_FILE"

  echo -e "\nSummary CSV: $SUMMARY" | tee -a "$STATS_FILE"
}
# -------------------------
# Main
# -------------------------
main() {
  setup
  run_load
  aggregate
  stats
}
main
