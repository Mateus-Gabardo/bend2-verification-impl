# Lemas genéricos usados pelas provas. Iguais na v0 e na v1.

import Base
import ./src/stock.bend as Stock
import ./src/validation.bend as Val
import ./src/search.bend as Search
import ./SPEC.bend as Spec
# a busca exatamente como reserve a chama, com a função anônima de seleção
def upd(stock: List<&2, Stock.Product>, id: Nat, qty: Nat) -> Maybe<&2, List<&2, Stock.Product>>:
  Search.update_where(~(p => i => Search.same_id(p, i)), stock, id, qty)

# Lemas sobre naturais
# --------------------

# x + 0 = x
law add_zero_r:
  for x: Nat
  {x == Nat.add(x, 0n) : Nat}

def add_zero_r(x):
  match x:
    case 0n:
      {==}
    case 1n+p:
      %add_zero_r(p) : {1n+p == 1n+_ : Nat}
      {==}

# a + (1 + b) = 1 + (a + b)
law add_succ:
  for a: Nat
  for +b: Nat
  {1n+Nat.add(a, b) == Nat.add(a, 1n+b) : Nat}

def add_succ(a, b):
  match a:
    case 0n:
      {==}
    case 1n+p:
      %add_succ(p, b) : {2n+Nat.add(p, b) == 1n+_ : Nat}
      {==}

# todo natural é igual a si mesmo: o critério de seleção acha o produto
law is_eq_refl:
  for i: Nat
  {True{} == Nat.is_eq(i, i) : Bool}

def is_eq_refl(i):
  match i:
    case 0n:
      {==}
    case 1n+p:
      is_eq_refl(p)

# identificadores diferentes: o critério de seleção pula o produto
law is_eq_distinct:
  for j: Nat
  for i: Nat
  for d: Spec.Distinct(j, i)
  {False{} == Nat.is_eq(j, i) : Bool}

def is_eq_distinct(j, i, d):
  match j i:
    case 0n 0n:
      match d:
    case 0n 1n+b:
      {==}
    case 1n+a 0n:
      {==}
    case 1n+a 1n+b:
      is_eq_distinct(a, b, d)

# Lemas sobre a validação (take)
# ------------------------------

# retirar q de q+m deixa m (inclusive m = 0)
law take_ok:
  for q: Nat
  for m: Nat
  {Some{m} == Val.take(q, Nat.add(q, m)) : Maybe<&2, Nat>}

def take_ok(q, m):
  match q:
    case 0n:
      {==}
    case 1n+p:
      take_ok(p, m)

# retirar mais que a recusa
law take_no:
  for a: Nat
  for +k: Nat
  {None{} == Val.take(1n+Nat.add(a, k), a) : Maybe<&2, Nat>}

def take_no(a, k):
  match a:
    case 0n:
      {==}
    case 1n+p:
      take_no(p, k)
