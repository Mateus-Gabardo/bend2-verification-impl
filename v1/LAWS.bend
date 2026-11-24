# Leis da reserva. Iguais em todas as versões.
# P1-P5: propriedades gerais (valem para qualquer entrada)
# T1-T5: testes unitários (uma entrada cada)

import Base
import ./src/stock.bend as Stock
import ./src/reserve.bend as Res
import ./SPEC.bend as Spec

# P1: pedido válido sai do disponível e entra no reservado;
#     os demais produtos ficam iguais
law accept_updates:
  for +pre  : List<&2, Stock.Product>
  for +i    : Nat
  for ok    : Spec.Absent(i, pre)
  for +q    : Nat
  for +m    : Nat
  for +h    : Nat
  for +rest : List<&2, Stock.Product>
  {Res.reserve(List.append(&2, Stock.Product, pre, Stock.Product{i, Nat.add(1n+q, m), h} <> rest), i, 1n+q)
    == Stock.Accepted{List.append(&2, Stock.Product, pre, Stock.Product{i, m, Nat.add(h, 1n+q)} <> rest)}
    : Stock.Outcome}

# P2: a soma disponível + reservado não muda
law conserve_total:
  for +s : List<&2, Stock.Product>
  for +i : Nat
  for +q : Nat
  {Spec.total(Spec.stock_of(Res.reserve(s, i, q))) == Spec.total(s) : Nat}

# P3: pedido maior que o disponível é recusado
law refuse_excess:
  for +pre  : List<&2, Stock.Product>
  for +i    : Nat
  for ok    : Spec.Absent(i, pre)
  for +a    : Nat
  for +h    : Nat
  for +k    : Nat
  for +rest : List<&2, Stock.Product>
  {Res.reserve(List.append(&2, Stock.Product, pre, Stock.Product{i, a, h} <> rest), i, Nat.add(a, 1n+k))
    == Stock.Refused{List.append(&2, Stock.Product, pre, Stock.Product{i, a, h} <> rest)}
    : Stock.Outcome}

# P4: pedido zero é recusado
law refuse_zero:
  for +s : List<&2, Stock.Product>
  for +i : Nat
  {Res.reserve(s, i, 0n) == Stock.Refused{s} : Stock.Outcome}

# P5: produto inexistente é recusado
law refuse_missing:
  for +s : List<&2, Stock.Product>
  for +i : Nat
  for ok : Spec.Absent(i, s)
  for +q : Nat
  {Res.reserve(s, i, q) == Stock.Refused{s} : Stock.Outcome}

# T1: reserva 3 do produto 7
law t1_accept_first:
  {Res.reserve(Spec.sample(), 7n, 3n)
    == Stock.Accepted{[Stock.Product{7n, 7n, 5n}, Stock.Product{8n, 5n, 0n}]} : Stock.Outcome}

# T2: reserva 2 do produto 8
law t2_accept_second:
  {Res.reserve(Spec.sample(), 8n, 2n)
    == Stock.Accepted{[Stock.Product{7n, 10n, 2n}, Stock.Product{8n, 3n, 2n}]} : Stock.Outcome}

# T3: pede 11 do produto 7 (só há 10)
law t3_refuse_excess:
  {Res.reserve(Spec.sample(), 7n, 11n) == Stock.Refused{Spec.sample()} : Stock.Outcome}

# T4: pede zero
law t4_refuse_zero:
  {Res.reserve(Spec.sample(), 7n, 0n) == Stock.Refused{Spec.sample()} : Stock.Outcome}

# T5: pede o produto 9, que não existe
law t5_refuse_missing:
  {Res.reserve(Spec.sample(), 9n, 1n) == Stock.Refused{Spec.sample()} : Stock.Outcome}
