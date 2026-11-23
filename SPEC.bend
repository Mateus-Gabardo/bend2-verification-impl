# Definições auxiliares usadas pelas leis de LAWS.bend; não fazem parte do
# programa. Mantenha este arquivo e LAWS.bend inalterados ao reescrever
# main.bend ou PROOF.bend (inclusive na versão gerada pela LLM).

import Base
import ./main.bend as R

# Distinct(a, b): Unit quando a e b são naturais diferentes, Empty quando iguais
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

# Absent(i, xs): nenhum produto de xs tem o identificador i
def Absent(i: Nat, xs: List<&2, R.Product>) -> Type:
  match xs:
    case Nil{}:
      Unit
    case R.Product{j, a, h} <> t:
      (Distinct(j, i) & Absent(i, t))

# soma de disponível e reservado de todos os produtos da lista
def total(xs: List<&2, R.Product>) -> Nat:
  match xs:
    case Nil{}:
      0n
    case R.Product{j, a, h} <> t:
      Nat.add(Nat.add(a, h), total(t))

# o estoque devolvido, seja a reserva aceita ou recusada
def stock_of(r: R.Outcome) -> List<&2, R.Product>:
  match r:
    case R.Accepted{s}:
      s
    case R.Refused{s}:
      s

# estoque de exemplo usado pelos testes unitários
def sample() -> List<&2, R.Product>:
  [R.Product{7n, 10n, 2n}, R.Product{8n, 5n, 0n}]
