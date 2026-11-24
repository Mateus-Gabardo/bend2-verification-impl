# Definições usadas só para escrever as leis (não fazem parte do programa).

import Base
import ./src/stock.bend as Stock

# a e b são diferentes?
def Distinct(a: Nat, b: Nat) -> Data:
  match a b:
    case 0n 0n:
      Empty
    case 0n 1n+b1:
      Unit
    case 1n+a1 0n:
      Unit
    case 1n+a1 1n+b1:
      Distinct(a1, b1)

# nenhum produto de xs tem o identificador i
def Absent(i: Nat, xs: List<&2, Stock.Product>) -> Type:
  match xs:
    case Nil{}:
      Unit
    case Stock.Product{j, a, h} <> t:
      (Distinct(j, i) & Absent(i, t))

# soma de disponível + reservado de todos os produtos
def total(xs: List<&2, Stock.Product>) -> Nat:
  match xs:
    case Nil{}:
      0n
    case Stock.Product{j, a, h} <> t:
      Nat.add(Nat.add(a, h), total(t))

# o estoque devolvido, aceita ou recusada
def stock_of(r: Stock.Outcome) -> List<&2, Stock.Product>:
  match r:
    case Stock.Accepted{s}:
      s
    case Stock.Refused{s}:
      s

# estoque usado pelos testes T1-T5
def sample() -> List<&2, Stock.Product>:
  [Stock.Product{7n, 10n, 2n}, Stock.Product{8n, 5n, 0n}]
