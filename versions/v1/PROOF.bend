# PROOF.bend da v0 ADAPTADO à v1 (registrado em llm/prompt.md):
#   - removidos upd_accept (P1) e os lemas da conservação (P2), que dependem
#     de put_head manter o produto atualizado na lista;
#   - P1 e P2 ficam abertas (?TODO): são FALSAS na v1 (checks/sold_out_*.bend);
#   - o restante é cópia literal da v0 e continua aceito (P3, P4, P5, T1-T5).
#
#   esperado: SOME PROOFS FAIL / 2 TODOs found

import Base
import ./src/stock.bend as Stock
import ./src/validation.bend as Val
import ./src/search.bend as Search
import ./src/reserve.bend as Res
import ./SPEC.bend as Spec
import ./LAWS.bend as Laws
import ./LEMMAS.bend as L

# Busca: o que update_where devolve em cada situação
# --------------------------------------------------

# P3: produto i depois de pre (sem i), pedido acima do disponível
law upd_excess:
  for +pre  : List<&2, Stock.Product>
  for +i    : Nat
  for ok    : Spec.Absent(i, pre)
  for +a    : Nat
  for +h    : Nat
  for +k    : Nat
  for +rest : List<&2, Stock.Product>
  {None{} == L.upd(List.append(&2, Stock.Product, pre, Stock.Product{i, a, h} <> rest), i, 1n+Nat.add(a, k))
    : Maybe<&2, List<&2, Stock.Product>>}

def upd_excess(pre, i, ok, a, h, k, rest):
  match pre:
    case Nil{}:
      %L.is_eq_refl(i) : {None{}
        == Search.update_where.pick(
             Search.put_head(Val.reserve_item(Stock.Product{i, a, h}, 1n+Nat.add(a, k)), rest),
             Search.keep_head(Stock.Product{i, a, h}, L.upd(rest, i, 1n+Nat.add(a, k))),
             _)
        : Maybe<&2, List<&2, Stock.Product>>}
      %L.take_no(a, k) : {None{}
        == Search.put_head(Val.reserve_item.fin(Stock.Product{i, a, h}, 1n+Nat.add(a, k), _), rest)
        : Maybe<&2, List<&2, Stock.Product>>}
      {==}
    case Stock.Product{j, aa, hh} <> t:
      (d, okt) = ok
      %L.is_eq_distinct(j, i, d) : {None{}
        == Search.update_where.pick(
             Search.put_head(Val.reserve_item(Stock.Product{j, aa, hh}, 1n+Nat.add(a, k)), List.append(&2, Stock.Product, t, Stock.Product{i, a, h} <> rest)),
             Search.keep_head(Stock.Product{j, aa, hh}, L.upd(List.append(&2, Stock.Product, t, Stock.Product{i, a, h} <> rest), i, 1n+Nat.add(a, k))),
             _)
        : Maybe<&2, List<&2, Stock.Product>>}
      %upd_excess(t, i, okt, a, h, k, rest) : {None{}
        == Search.keep_head(Stock.Product{j, aa, hh}, _)
        : Maybe<&2, List<&2, Stock.Product>>}
      {==}

# P5: nenhum produto tem o identificador i
law upd_missing:
  for +s   : List<&2, Stock.Product>
  for +i   : Nat
  for ok   : Spec.Absent(i, s)
  for +qty : Nat
  {None{} == L.upd(s, i, qty) : Maybe<&2, List<&2, Stock.Product>>}

def upd_missing(s, i, ok, qty):
  match s:
    case Nil{}:
      {==}
    case Stock.Product{j, a, h} <> t:
      (d, okt) = ok
      %L.is_eq_distinct(j, i, d) : {None{}
        == Search.update_where.pick(
             Search.put_head(Val.reserve_item(Stock.Product{j, a, h}, qty), t),
             Search.keep_head(Stock.Product{j, a, h}, L.upd(t, i, qty)),
             _)
        : Maybe<&2, List<&2, Stock.Product>>}
      %upd_missing(t, i, okt, qty) : {None{}
        == Search.keep_head(Stock.Product{j, a, h}, _)
        : Maybe<&2, List<&2, Stock.Product>>}
      {==}

# Leis
# ----

# Testes unitários: os dois lados calculam o mesmo valor
def Laws.t1_accept_first():
  {==}

def Laws.t2_accept_second():
  {==}

def Laws.t3_refuse_excess():
  {==}

def Laws.t4_refuse_zero():
  {==}

def Laws.t5_refuse_missing():
  {==}

# P1: FALSA na v1 (contraexemplo: checks/sold_out_p1.bend)
def Laws.accept_updates(pre, i, ok, q, m, h, rest):
  ?TODO

# P2: FALSA na v1 (contraexemplo: checks/sold_out_p2.bend)
def Laws.conserve_total(s, i, q):
  ?TODO

# P3: primeiro escreve a+(1+k) como 1+(a+k), depois usa upd_excess
def Laws.refuse_excess(pre, i, ok, a, h, k, rest):
  %L.add_succ(a, k) : {Res.reserve(List.append(&2, Stock.Product, pre, Stock.Product{i, a, h} <> rest), i, _)
    == Stock.Refused{List.append(&2, Stock.Product, pre, Stock.Product{i, a, h} <> rest)}
    : Stock.Outcome}
  %upd_excess(pre, i, ok, a, h, k, rest) : {Res.reserve.fin(List.append(&2, Stock.Product, pre, Stock.Product{i, a, h} <> rest), _)
    == Stock.Refused{List.append(&2, Stock.Product, pre, Stock.Product{i, a, h} <> rest)}
    : Stock.Outcome}
  {==}

# P4: com qty = 0, reserve devolve Refused{s} direto
def Laws.refuse_zero(s, i):
  {==}

# P5: pedido nulo é recusado direto; os demais, por upd_missing
def Laws.refuse_missing(s, i, ok, q):
  match q:
    case 0n:
      {==}
    case 1n+p:
      %upd_missing(s, i, ok, 1n+p) : {Res.reserve.fin(s, _) == Stock.Refused{s} : Stock.Outcome}
      {==}
