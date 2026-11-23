# reserve: a operação de reserva.

import Base
import ./stock.bend as Stock
import ./search.bend as Search

# [casamento de padrões] converte o resultado da busca na decisão
def reserve.fin(stock: List<&2, Stock.Product>, r: Maybe<&2, List<&2, Stock.Product>>) -> Stock.Outcome:
  match r:
    case Some{s2}:
      Stock.Accepted{s2}
    case None{}:
      Stock.Refused{stock}

# [função nomeada] [função anônima] [casamento de padrões]
# reserve: recusa o pedido nulo; nos demais, passa à busca a função anônima
# p => i => same_id(p, i) como critério de seleção
def reserve(+stock: List<&2, Stock.Product>, +id: Nat, qty: Nat) -> Stock.Outcome:
  match qty:
    case 0n:
      Stock.Refused{stock}
    case 1n+q:
      reserve.fin(stock, Search.update_where(~(p => i => Search.same_id(p, i)), stock, id, 1n+q))
