# Caso esgotado: pede todo o disponível do produto 7.
# Passa na v0, falha na v1 (o produto some da lista).

import Base
import ./src/stock.bend as Stock
import ./src/reserve.bend as Res
import ./SPEC.bend as Spec

law sold_out_p1:
  {Res.reserve([Stock.Product{7n, 3n, 2n}, Stock.Product{8n, 5n, 0n}], 7n, 3n)
    == Stock.Accepted{[Stock.Product{7n, 0n, 5n}, Stock.Product{8n, 5n, 0n}]} : Stock.Outcome}

def sold_out_p1():
  {==}
