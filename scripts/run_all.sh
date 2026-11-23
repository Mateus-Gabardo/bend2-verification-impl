#!/bin/sh
# Monta cada versão, roda todas as verificações e grava as saídas em logs/.
#
#   sh scripts/run_all.sh
#
# build/ é temporária (fora do git): para cada versão, o script copia nela o
# projeto da raiz e, por cima, os arquivos da versão. Depois de rodar, dá para
# entrar em build/<versão>/ e repetir qualquer comando à mão.
#   build/v0       = o projeto da raiz
#   build/v1       = a raiz + versions/v1/src/search.bend (módulo alterado pela LLM)
#   build/v1-adapt = build/v1 + versions/v1/PROOF.bend (provas adaptadas)
# SPEC.bend e LAWS.bend nunca são sobrescritos: as leis são as mesmas.
set -u

BEND=${BEND:-$HOME/.bend/bin/bend}
ROOT=$(cd "$(dirname "$0")/.." && pwd)
LOGS="$ROOT/logs"
rm -rf "$ROOT/build" "$LOGS" && mkdir -p "$ROOT/build" "$LOGS"

# build <nome> <versão> [adapt]
build() {
  d="$ROOT/build/$1"
  mkdir -p "$d"
  cp -r "$ROOT/main.bend" "$ROOT/src" "$ROOT/SPEC.bend" "$ROOT/LAWS.bend" \
    "$ROOT/LEMMAS.bend" "$ROOT/PROOF.bend" "$ROOT"/checks/*.bend "$d/"
  if [ "$2" != v0 ]; then
    cp "$ROOT/versions/$2/src/"*.bend "$d/src/"
    [ "${3:-}" = adapt ] && cp "$ROOT/versions/$2/PROOF.bend" "$d/PROOF.bend"
  fi
}

# run <pasta> <arquivo>: roda bend, grava logs/<pasta>.<arquivo>.txt e resume
run() {
  log="$LOGS/$1.$(basename "$2" .bend).txt"
  (cd "$ROOT/build/$1" && { echo "\$ bend $2    # build/$1"; "$BEND" "$2"; echo "exit=$?"; }) > "$log" 2>&1
  printf '%-10s %-18s %s\n' "$1" "$2" \
    "$(grep -m1 -E 'ALL PROOFS CHECK|SOME PROOFS FAIL|TODOs? found|Accepted' "$log" | sed 's/.*Error: //')" \
    | tee -a "$LOGS/resultados.txt"
}

build v0 v0
build v1 v1
build v1-adapt v1 adapt

for d in v0 v1; do
  run $d main.bend
  run $d PROOF.bend
  [ $d = v1 ] && run v1-adapt PROOF.bend
  run $d blind_spot.bend
  run $d sold_out_p1.bend
  run $d sold_out_p2.bend
done

{ date -Iseconds; "$BEND" version; uname -sr; lsb_release -ds 2>/dev/null; } > "$LOGS/ambiente.txt"
