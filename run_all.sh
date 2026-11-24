#!/bin/sh
# Roda todas as verificações nas duas versões e grava as saídas em logs/.
#   sh run_all.sh
set -u
BEND=${BEND:-$HOME/.bend/bin/bend}
ROOT=$(cd "$(dirname "$0")" && pwd)
LOGS="$ROOT/logs"
rm -rf "$LOGS" && mkdir -p "$LOGS"

# run <pasta> <arquivo> [nome do log]
run() {
  log="$LOGS/${3:-$1.$(basename "$2" .bend)}.txt"
  (cd "$ROOT/$1" && { echo "\$ bend $2    # pasta $1"; "$BEND" "$2"; echo "exit=$?"; }) > "$log" 2>&1
  printf '%-4s %-18s %s\n' "$1" "$2" \
    "$(grep -m1 -E 'ALL PROOFS CHECK|SOME PROOFS FAIL|Accepted' "$log")" | tee -a "$LOGS/resultados.txt"
}

for v in v0 v1; do
  for f in main.bend PROOF.bend unit_tests.bend blind_spot.bend sold_out_p1.bend sold_out_p2.bend; do
    run $v $f
  done
done

# as provas da v0, sem adaptação, aplicadas à v1: falham em P1
tmp=$(mktemp -d) && cp -r "$ROOT/v1/." "$tmp" && cp "$ROOT/v0/PROOF.bend" "$tmp/"
(cd "$tmp" && { echo "\$ bend PROOF.bend    # provas da v0 na v1"; "$BEND" PROOF.bend; echo "exit=$?"; }) > "$LOGS/v1.PROOF_da_v0.txt" 2>&1
printf '%-4s %-18s %s\n' v1 "PROOF (da v0)" "$(grep -m1 -E 'ALL PROOFS CHECK|SOME PROOFS FAIL' "$LOGS/v1.PROOF_da_v0.txt")" | tee -a "$LOGS/resultados.txt"
rm -rf "$tmp"

{ date -Iseconds; "$BEND" version; uname -sr; lsb_release -ds 2>/dev/null; } > "$LOGS/ambiente.txt"
