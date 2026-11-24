# Só os testes T1-T5. Passam na v0 e também na v1 (não pegam o erro).

import Base
import ./src/stock.bend as Stock
import ./src/reserve.bend as Res
import ./SPEC.bend as Spec

# T1
law t1_accept_first:
  {Res.reserve(Spec.sample(), 7n, 3n)
    == Stock.Accepted{[Stock.Product{7n, 7n, 5n}, Stock.Product{8n, 5n, 0n}]} : Stock.Outcome}

# T1
def t1_accept_first():
  {==}

# T2
law t2_accept_second:
  {Res.reserve(Spec.sample(), 8n, 2n)
    == Stock.Accepted{[Stock.Product{7n, 10n, 2n}, Stock.Product{8n, 3n, 2n}]} : Stock.Outcome}

# T2
def t2_accept_second():
  {==}

# T3
law t3_refuse_excess:
  {Res.reserve(Spec.sample(), 7n, 11n) == Stock.Refused{Spec.sample()} : Stock.Outcome}

# T3
def t3_refuse_excess():
  {==}

# T4
law t4_refuse_zero:
  {Res.reserve(Spec.sample(), 7n, 0n) == Stock.Refused{Spec.sample()} : Stock.Outcome}

# T4
def t4_refuse_zero():
  {==}

# T5
law t5_refuse_missing:
  {Res.reserve(Spec.sample(), 9n, 1n) == Stock.Refused{Spec.sample()} : Stock.Outcome}

# T5
def t5_refuse_missing():
  {==}
