# hello: um cálculo simples, uma lei sobre ele e o print do resultado.
# O bend confere a lei PRIMEIRO; só se ela estiver provada o main roda.
#
#   bend examples/hello.bend
#
# saída esperada:
#   Hello, world!
#   add_two(3) = 5
#
# Para ver a regra funcionando, troque 2n+n por 3n+n em add_two e rode de
# novo: o bend imprime SOME PROOFS FAIL e NÃO imprime nada do main.

import Base

# o cálculo: soma 2 a n
def add_two(n: Nat) -> Nat:
  2n+n

# LEI: para todo n, add_two(n) é igual a 2 + n (somado pela Base)
law add_two_is_plus_two:
  for n: Nat
  {add_two(n) == Nat.add(2n, n) : Nat}

# PROVA: os dois lados calculam o mesmo termo, 2n+n, então {==} basta
def add_two_is_plus_two(n):
  {==}

def main() -> IO(Unit):
  do IO<Unit>:
    IO.print("Hello, world!")
    IO.print("add_two(3) = " ++ Nat.show(add_two(3n)))
