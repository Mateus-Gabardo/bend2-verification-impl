# stock_reservation: as leis. Os autores as escrevem; PROOF.bend deve
# prová-las. As mesmas leis valem para todas as versões de main.bend.
# P1-P5 são propriedades gerais (para todas as entradas); T1-T5 são testes
# unitários (entradas concretas). Nenhum teste esgota o produto.

import Base
import ./src/stock.bend as Stock
import ./src/reserve.bend as Res
import ./SPEC.bend as Spec

# Propriedades gerais
# -------------------

# LEI P1 (atualização correta e demais produtos preservados): o produto i,
# precedido por produtos de outros identificadores (pre) e seguido por
# qualquer cauda (rest), com (1+q)+m disponíveis, recebe um pedido de 1+q
# unidades. A reserva é aceita; o disponível passa a m (inclusive m = 0,
# produto esgotado) e o reservado passa a h+(1+q); pre e rest ficam iguais
# e na mesma ordem.
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

# LEI P2 (conservação): para qualquer estoque, identificador e quantidade,
# com a reserva aceita ou recusada, o estoque devolvido tem a mesma soma de
# disponível e reservado que o estoque recebido
law conserve_total:
  for +s : List<&2, Stock.Product>
  for +i : Nat
  for +q : Nat
  {Spec.total(Spec.stock_of(Res.reserve(s, i, q))) == Spec.total(s) : Nat}

# LEI P3 (recusa por indisponibilidade): pedir a+(1+k) unidades de um
# produto com a disponíveis é recusado e devolve o estoque recebido
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

# LEI P4 (recusa de pedido nulo): pedir 0 unidades é recusado e devolve o
# estoque recebido
law refuse_zero:
  for +s : List<&2, Stock.Product>
  for +i : Nat
  {Res.reserve(s, i, 0n) == Stock.Refused{s} : Stock.Outcome}

# LEI P5 (recusa de produto inexistente): se nenhum produto tem o
# identificador i, o pedido é recusado e devolve o estoque recebido
law refuse_missing:
  for +s : List<&2, Stock.Product>
  for +i : Nat
  for ok : Spec.Absent(i, s)
  for +q : Nat
  {Res.reserve(s, i, q) == Stock.Refused{s} : Stock.Outcome}

# Testes unitários sobre Spec.sample() = [Product{7, 10, 2}, Product{8, 5, 0}]
# ----------------------------------------------------------------------------

# LEI T1: reserva parcial do primeiro produto
law t1_accept_first:
  {Res.reserve(Spec.sample(), 7n, 3n)
    == Stock.Accepted{[Stock.Product{7n, 7n, 5n}, Stock.Product{8n, 5n, 0n}]} : Stock.Outcome}

# LEI T2: reserva do segundo produto; o primeiro fica igual
law t2_accept_second:
  {Res.reserve(Spec.sample(), 8n, 2n)
    == Stock.Accepted{[Stock.Product{7n, 10n, 2n}, Stock.Product{8n, 3n, 2n}]} : Stock.Outcome}

# LEI T3: pedido acima do disponível
law t3_refuse_excess:
  {Res.reserve(Spec.sample(), 7n, 11n) == Stock.Refused{Spec.sample()} : Stock.Outcome}

# LEI T4: pedido nulo
law t4_refuse_zero:
  {Res.reserve(Spec.sample(), 7n, 0n) == Stock.Refused{Spec.sample()} : Stock.Outcome}

# LEI T5: produto inexistente
law t5_refuse_missing:
  {Res.reserve(Spec.sample(), 9n, 1n) == Stock.Refused{Spec.sample()} : Stock.Outcome}
