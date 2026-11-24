# stock_reservation: as provas. Cada lei de LAWS.bend é provada por um def
# chamado Laws.<lei>. Lemas auxiliares ficam acima de quem os usa.
#
# Como ler uma prova:
#   {==}          os dois lados calculam o mesmo valor
#   match x:      análise de casos; cada caso refina o objetivo
#   f(menor)      chamada recursiva = hipótese de indução
#   %e : P        reescrita: usa a igualdade e : {a == b} para trocar b por a
#                 no objetivo P (o _ marca onde b estava)
#   x => ...      prova de uma implicação (recebe a hipótese x)
#
#   bend PROOF.bend   -> ALL PROOFS CHECK

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

# P1: produto i depois de pre (sem i), com disponível suficiente
law upd_accept:
  for +pre  : List<&2, Stock.Product>
  for +i    : Nat
  for ok    : Spec.Absent(i, pre)
  for +q    : Nat
  for +m    : Nat
  for +h    : Nat
  for +rest : List<&2, Stock.Product>
  {Some{List.append(&2, Stock.Product, pre, Stock.Product{i, m, Nat.add(h, 1n+q)} <> rest)}
    == L.upd(List.append(&2, Stock.Product, pre, Stock.Product{i, Nat.add(1n+q, m), h} <> rest), i, 1n+q)
    : Maybe<&2, List<&2, Stock.Product>>}

def upd_accept(pre, i, ok, q, m, h, rest):
  match pre:
    case Nil{}:
      # o próprio produto i: o critério dá True e take dá Some{m}
      %L.is_eq_refl(i) : {Some{Stock.Product{i, m, Nat.add(h, 1n+q)} <> rest}
        == Search.update_where.pick(
             Search.put_head(Val.reserve_item(Stock.Product{i, Nat.add(1n+q, m), h}, 1n+q), rest),
             Search.keep_head(Stock.Product{i, Nat.add(1n+q, m), h}, L.upd(rest, i, 1n+q)),
             _)
        : Maybe<&2, List<&2, Stock.Product>>}
      %L.take_ok(q, m) : {Some{Stock.Product{i, m, Nat.add(h, 1n+q)} <> rest}
        == Search.put_head(Val.reserve_item.fin(Stock.Product{i, Nat.add(1n+q, m), h}, 1n+q, _), rest)
        : Maybe<&2, List<&2, Stock.Product>>}
      {==}
    case Stock.Product{j, a, hh} <> t:
      # outro produto: o critério dá False, ele é mantido, e a busca segue
      (d, okt) = ok
      %L.is_eq_distinct(j, i, d) : {Some{Stock.Product{j, a, hh} <> List.append(&2, Stock.Product, t, Stock.Product{i, m, Nat.add(h, 1n+q)} <> rest)}
        == Search.update_where.pick(
             Search.put_head(Val.reserve_item(Stock.Product{j, a, hh}, 1n+q), List.append(&2, Stock.Product, t, Stock.Product{i, Nat.add(1n+q, m), h} <> rest)),
             Search.keep_head(Stock.Product{j, a, hh}, L.upd(List.append(&2, Stock.Product, t, Stock.Product{i, Nat.add(1n+q, m), h} <> rest), i, 1n+q)),
             _)
        : Maybe<&2, List<&2, Stock.Product>>}
      %upd_accept(t, i, okt, q, m, h, rest) : {Some{Stock.Product{j, a, hh} <> List.append(&2, Stock.Product, t, Stock.Product{i, m, Nat.add(h, 1n+q)} <> rest)}
        == Search.keep_head(Stock.Product{j, a, hh}, _)
        : Maybe<&2, List<&2, Stock.Product>>}
      {==}

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

# Conservação (P2)
# ----------------

# o total do estoque que resulta da busca: o novo, se aceita; o original, se não
def tot(s: List<&2, Stock.Product>, r: Maybe<&2, List<&2, Stock.Product>>) -> Nat:
  match r:
    case Some{s2}:
      Spec.total(s2)
    case None{}:
      Spec.total(s)

# disponível + reservado de um produto depois da tentativa de retirar n
def item_total(h: Nat, n: Nat, a: Nat, r: Maybe<&2, Nat>) -> Nat:
  match r:
    case Some{a2}:
      Nat.add(a2, Nat.add(h, n))
    case None{}:
      Nat.add(a, h)

# um passo de take: tirar 1 de cada lado soma 1 ao total do produto
law item_step:
  for +h  : Nat
  for +np : Nat
  for +ap : Nat
  for r   : Maybe<&2, Nat>
  {1n+item_total(h, np, ap, r) == item_total(h, 1n+np, 1n+ap, r) : Nat}

def item_step(h, np, ap, r):
  match r:
    case Some{a2}:
      +a2 = a2
      %L.add_succ(h, np) : {1n+Nat.add(a2, Nat.add(h, np)) == Nat.add(a2, _) : Nat}
      %L.add_succ(a2, Nat.add(h, np)) : {1n+Nat.add(a2, Nat.add(h, np)) == _ : Nat}
      {==}
    case None{}:
      {==}

# retirar n de a não muda disponível + reservado do produto
law item_conserve:
  for +n : Nat
  for +a : Nat
  for +h : Nat
  {Nat.add(a, h) == item_total(h, n, a, Val.take(n, a)) : Nat}

def item_conserve(n, a, h):
  match n a:
    case 0n _:
      %L.add_zero_r(h) : {Nat.add(a, h) == Nat.add(a, _) : Nat}
      {==}
    case 1n+np 0n:
      {==}
    case 1n+np 1n+ap:
      %item_step(h, np, ap, Val.take(np, ap)) : {1n+Nat.add(ap, h) == _ : Nat}
      %item_conserve(np, ap, h) : {1n+Nat.add(ap, h) == 1n+_ : Nat}
      {==}

# produto escolhido: o total da lista é o do produto atualizado mais a cauda
law tot_found:
  for +j   : Nat
  for +a   : Nat
  for +h   : Nat
  for +qty : Nat
  for +t   : List<&2, Stock.Product>
  for r    : Maybe<&2, Nat>
  {Nat.add(item_total(h, qty, a, r), Spec.total(t))
    == tot(Stock.Product{j, a, h} <> t, Search.put_head(Val.reserve_item.fin(Stock.Product{j, a, h}, qty, r), t))
    : Nat}

def tot_found(j, a, h, qty, t, r):
  match r:
    case Some{a2}:
      {==}
    case None{}:
      {==}

# produto mantido: se a busca na cauda conserva, a lista inteira conserva
law tot_kept:
  for +j : Nat
  for +a : Nat
  for +h : Nat
  for +t : List<&2, Stock.Product>
  for r  : Maybe<&2, List<&2, Stock.Product>>
  {tot(t, r) == Spec.total(t) : Nat} ->
    {tot(Stock.Product{j, a, h} <> t, Search.keep_head(Stock.Product{j, a, h}, r))
      == Spec.total(Stock.Product{j, a, h} <> t) : Nat}

def tot_kept(j, a, h, t, r):
  match r:
    case Some{s2}:
      ih => %ih : {Nat.add(Nat.add(a, h), Spec.total(s2)) == Nat.add(Nat.add(a, h), _) : Nat}
        {==}
    case None{}:
      ih => {==}

# um passo da busca, com o resultado do critério (hit) como parâmetro
law conserve_step:
  for +j   : Nat
  for +a   : Nat
  for +h   : Nat
  for +t   : List<&2, Stock.Product>
  for +i   : Nat
  for +qty : Nat
  for hit  : Bool
  for ih   : {tot(t, L.upd(t, i, qty)) == Spec.total(t) : Nat}
  {tot(Stock.Product{j, a, h} <> t,
      Search.update_where.pick(
        Search.put_head(Val.reserve_item(Stock.Product{j, a, h}, qty), t),
        Search.keep_head(Stock.Product{j, a, h}, L.upd(t, i, qty)),
        hit))
    == Spec.total(Stock.Product{j, a, h} <> t) : Nat}

def conserve_step(j, a, h, t, i, qty, hit, ih):
  match hit:
    case True{}:
      %tot_found(j, a, h, qty, t, Val.take(qty, a)) : {_ == Spec.total(Stock.Product{j, a, h} <> t) : Nat}
      %item_conserve(qty, a, h) : {Nat.add(_, Spec.total(t)) == Spec.total(Stock.Product{j, a, h} <> t) : Nat}
      {==}
    case False{}:
      tot_kept(j, a, h, t, L.upd(t, i, qty))(ih)

# a busca nunca muda o total do estoque
law conserve_upd:
  for +s   : List<&2, Stock.Product>
  for +i   : Nat
  for +qty : Nat
  {tot(s, L.upd(s, i, qty)) == Spec.total(s) : Nat}

def conserve_upd(s, i, qty):
  match s:
    case Nil{}:
      {==}
    case Stock.Product{j, a, h} <> t:
      conserve_step(j, a, h, t, i, qty, Nat.is_eq(j, i), conserve_upd(t, i, qty))

# o estoque devolvido por reserve.fin tem o total que tot calcula
law tot_fin:
  for +s : List<&2, Stock.Product>
  for r  : Maybe<&2, List<&2, Stock.Product>>
  {tot(s, r) == Spec.total(Spec.stock_of(Res.reserve.fin(s, r))) : Nat}

def tot_fin(s, r):
  match r:
    case Some{s2}:
      {==}
    case None{}:
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

# P1: reserve repassa à busca, e upd_accept diz o que ela devolve
def Laws.accept_updates(pre, i, ok, q, m, h, rest):
  %upd_accept(pre, i, ok, q, m, h, rest) : {Res.reserve.fin(List.append(&2, Stock.Product, pre, Stock.Product{i, Nat.add(1n+q, m), h} <> rest), _)
    == Stock.Accepted{List.append(&2, Stock.Product, pre, Stock.Product{i, m, Nat.add(h, 1n+q)} <> rest)}
    : Stock.Outcome}
  {==}

# P2: pedido nulo devolve o próprio estoque; os demais passam por conserve_upd
def Laws.conserve_total(s, i, q):
  match q:
    case 0n:
      {==}
    case 1n+p:
      %tot_fin(s, L.upd(s, i, 1n+p)) : {_ == Spec.total(s) : Nat}
      conserve_upd(s, i, 1n+p)

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
