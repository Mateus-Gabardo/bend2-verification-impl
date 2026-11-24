# Caso esgotado, soma total: passa na v0, falha na v1 (10 vira 5).

import Base
import ./src/stock.bend as Stock
import ./src/reserve.bend as Res
import ./SPEC.bend as Spec

law sold_out_p2:
  {Spec.total(Spec.stock_of(Res.reserve([Stock.Product{7n, 3n, 2n}, Stock.Product{8n, 5n, 0n}], 7n, 3n)))
    == Spec.total([Stock.Product{7n, 3n, 2n}, Stock.Product{8n, 5n, 0n}]) : Nat}

def sold_out_p2():
  {==}
