# sold_out: o caso que nenhum teste unitário cobre. É uma instância concreta
# de P1 com o produto esgotado (pedido igual ao disponível). Se a versão
# viola P1, a lei instanciada falha e o verificador mostra o valor
# obtido: é um contraexemplo, não apenas uma prova que não fechou.
#
#   esperado na v0: ALL PROOFS CHECK

import Base
import ./src/stock.bend as Stock
import ./src/reserve.bend as Res
import ./SPEC.bend as Spec

# P1 com pre = [], i = 7, q+1 = 3, m = 0, h = 2, rest = [Product{8, 5, 0}]
law sold_out_p1:
  {Res.reserve([Stock.Product{7n, 3n, 2n}, Stock.Product{8n, 5n, 0n}], 7n, 3n)
    == Stock.Accepted{[Stock.Product{7n, 0n, 5n}, Stock.Product{8n, 5n, 0n}]} : Stock.Outcome}

def sold_out_p1():
  {==}
