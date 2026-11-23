# law_demo: uma função, uma lei sobre ela e a prova dessa lei, num único
# arquivo. O bend confere a prova primeiro e só depois calcula main.
#
#   bend examples/law_demo.bend               -> 6n
#   bend examples/law_demo.bend --check-only  -> ALL PROOFS CHECK
#
# Troque 2n+double(p) por 3n+double(p) e os dois comandos imprimem
# SOME PROOFS FAIL, com os termos esperado (expected) e obtido (observed).

import Base

# double(n) = n + n, escrita por recursão sobre n
def double(n: Nat) -> Nat:
  match n:
    case 0n:
      0n
    case 1n+p:
      2n+double(p)

# LEI: para todo n, double(n) é igual ao Nat.double(n) da Base
law double_matches_base:
  for n: Nat
  {double(n) == Nat.double(n) : Nat}

# PROVA: por indução sobre n
# - 0n: os dois lados calculam 0n
# - 1n+p: os dois lados viram 2n+..., e a chamada recursiva prova o resto
def double_matches_base(n):
  match n:
    case 0n:
      {==}
    case 1n+p:
      %double_matches_base(p) : {2n+double(p) == 2n+_ : Nat}
      {==}

def main() -> Nat:
  double(3n)
