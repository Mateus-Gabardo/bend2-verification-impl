# sold_out: o caso que nenhum teste unitário cobre. É uma instância concreta
# de P2 com o produto esgotado (pedido igual ao disponível). Se a versão
# viola P2, a lei instanciada falha e o verificador mostra o valor
# obtido: é um contraexemplo, não apenas uma prova que não fechou.
#
#   esperado na v0: ALL PROOFS CHECK

import Base
import ./src/stock.bend as Stock
import ./src/reserve.bend as Res
import ./SPEC.bend as Spec

# P2 no estoque [Product{7, 3, 2}, Product{8, 5, 0}], pedido de 3 unidades
# do produto 7: total antes = (3+2)+(5+0) = 10
law sold_out_p2:
  {Spec.total(Spec.stock_of(Res.reserve([Stock.Product{7n, 3n, 2n}, Stock.Product{8n, 5n, 0n}], 7n, 3n)))
    == Spec.total([Stock.Product{7n, 3n, 2n}, Stock.Product{8n, 5n, 0n}]) : Nat}

def sold_out_p2():
  {==}
