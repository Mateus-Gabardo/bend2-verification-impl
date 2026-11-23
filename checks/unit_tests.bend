# unit_tests: os cinco testes unitários T1-T5, isolados das leis gerais.
# Cada teste é uma entrada concreta com o resultado esperado, sobre o estoque
# Spec.sample() = [Product{7, 10, 2}, Product{8, 5, 0}]. Nenhum deles pede
# todo o disponível de um produto.
#
#   esperado na v0 E na v1: ALL PROOFS CHECK
#   (os testes não percebem o erro da v1; ver checks/sold_out_p1.bend)

import Base
import ./src/stock.bend as Stock
import ./src/reserve.bend as Res
import ./SPEC.bend as Spec

# T1: reserva parcial do primeiro produto (3 das 10 unidades)
law t1_accept_first:
  {Res.reserve(Spec.sample(), 7n, 3n)
    == Stock.Accepted{[Stock.Product{7n, 7n, 5n}, Stock.Product{8n, 5n, 0n}]} : Stock.Outcome}

def t1_accept_first():
  {==}

# T2: reserva do segundo produto; o primeiro fica igual
law t2_accept_second:
  {Res.reserve(Spec.sample(), 8n, 2n)
    == Stock.Accepted{[Stock.Product{7n, 10n, 2n}, Stock.Product{8n, 3n, 2n}]} : Stock.Outcome}

def t2_accept_second():
  {==}

# T3: pedido acima do disponível
law t3_refuse_excess:
  {Res.reserve(Spec.sample(), 7n, 11n) == Stock.Refused{Spec.sample()} : Stock.Outcome}

def t3_refuse_excess():
  {==}

# T4: pedido nulo
law t4_refuse_zero:
  {Res.reserve(Spec.sample(), 7n, 0n) == Stock.Refused{Spec.sample()} : Stock.Outcome}

def t4_refuse_zero():
  {==}

# T5: produto inexistente
law t5_refuse_missing:
  {Res.reserve(Spec.sample(), 9n, 1n) == Stock.Refused{Spec.sample()} : Stock.Outcome}

def t5_refuse_missing():
  {==}
