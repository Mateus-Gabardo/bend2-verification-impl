# Ponto cego dos testes: fora do caso esgotado, a v1 dá o mesmo resultado
# que a v0 (P1 sem esgotar o produto). Passa na v0 e na v1.

import Base
import ./src/stock.bend as Stock
import ./src/validation.bend as Val
import ./src/search.bend as Search
import ./src/reserve.bend as Res
import ./SPEC.bend as Spec
import ./LEMMAS.bend as L

# a busca, no caso em que o produto não esgota
law upd_accept_in_stock:
  for +pre  : List<&2, Stock.Product>
  for +i    : Nat
  for ok    : Spec.Absent(i, pre)
  for +q    : Nat
  for +m    : Nat
  for +h    : Nat
  for +rest : List<&2, Stock.Product>
  {Some{List.append(&2, Stock.Product, pre, Stock.Product{i, 1n+m, Nat.add(h, 1n+q)} <> rest)}
    == L.upd(List.append(&2, Stock.Product, pre, Stock.Product{i, Nat.add(1n+q, 1n+m), h} <> rest), i, 1n+q)
    : Maybe<&2, List<&2, Stock.Product>>}

def upd_accept_in_stock(pre, i, ok, q, m, h, rest):
  match pre:
    case Nil{}:
      # o próprio produto i: o critério dá True e take dá Some{1n+m}
      %L.is_eq_refl(i) : {Some{Stock.Product{i, 1n+m, Nat.add(h, 1n+q)} <> rest}
        == Search.update_where.pick(
             Search.put_head(Val.reserve_item(Stock.Product{i, Nat.add(1n+q, 1n+m), h}, 1n+q), rest),
             Search.keep_head(Stock.Product{i, Nat.add(1n+q, 1n+m), h}, L.upd(rest, i, 1n+q)),
             _)
        : Maybe<&2, List<&2, Stock.Product>>}
      %L.take_ok(q, 1n+m) : {Some{Stock.Product{i, 1n+m, Nat.add(h, 1n+q)} <> rest}
        == Search.put_head(Val.reserve_item.fin(Stock.Product{i, Nat.add(1n+q, 1n+m), h}, 1n+q, _), rest)
        : Maybe<&2, List<&2, Stock.Product>>}
      {==}
    case Stock.Product{j, a, hh} <> t:
      # outro produto: o critério dá False, ele é mantido, e a busca segue
      (d, okt) = ok
      %L.is_eq_distinct(j, i, d) : {Some{Stock.Product{j, a, hh} <> List.append(&2, Stock.Product, t, Stock.Product{i, 1n+m, Nat.add(h, 1n+q)} <> rest)}
        == Search.update_where.pick(
             Search.put_head(Val.reserve_item(Stock.Product{j, a, hh}, 1n+q), List.append(&2, Stock.Product, t, Stock.Product{i, Nat.add(1n+q, 1n+m), h} <> rest)),
             Search.keep_head(Stock.Product{j, a, hh}, L.upd(List.append(&2, Stock.Product, t, Stock.Product{i, Nat.add(1n+q, 1n+m), h} <> rest), i, 1n+q)),
             _)
        : Maybe<&2, List<&2, Stock.Product>>}
      %upd_accept_in_stock(t, i, okt, q, m, h, rest) : {Some{Stock.Product{j, a, hh} <> List.append(&2, Stock.Product, t, Stock.Product{i, 1n+m, Nat.add(h, 1n+q)} <> rest)}
        == Search.keep_head(Stock.Product{j, a, hh}, _)
        : Maybe<&2, List<&2, Stock.Product>>}
      {==}

# LEI: P1 quando o produto não esgota (disponível final = 1+m)
law accept_updates_in_stock:
  for +pre  : List<&2, Stock.Product>
  for +i    : Nat
  for ok    : Spec.Absent(i, pre)
  for +q    : Nat
  for +m    : Nat
  for +h    : Nat
  for +rest : List<&2, Stock.Product>
  {Res.reserve(List.append(&2, Stock.Product, pre, Stock.Product{i, Nat.add(1n+q, 1n+m), h} <> rest), i, 1n+q)
    == Stock.Accepted{List.append(&2, Stock.Product, pre, Stock.Product{i, 1n+m, Nat.add(h, 1n+q)} <> rest)}
    : Stock.Outcome}

def accept_updates_in_stock(pre, i, ok, q, m, h, rest):
  %upd_accept_in_stock(pre, i, ok, q, m, h, rest) : {Res.reserve.fin(List.append(&2, Stock.Product, pre, Stock.Product{i, Nat.add(1n+q, 1n+m), h} <> rest), _)
    == Stock.Accepted{List.append(&2, Stock.Product, pre, Stock.Product{i, 1n+m, Nat.add(h, 1n+q)} <> rest)}
    : Stock.Outcome}
  {==}
