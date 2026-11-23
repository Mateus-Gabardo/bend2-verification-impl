# reserve: a operação de reserva.

import Base
import ./stock.bend as Stock
import ./search.bend as Search

# [casamento de padrões] converte o resultado da busca na decisão:
# Some{s2} é o estoque atualizado (reserva aceita); None{} é a recusa, e então
# devolve-se o estoque recebido, sem alterações.
def reserve.fin(stock: List<&2, Stock.Product>, r: Maybe<&2, List<&2, Stock.Product>>) -> Stock.Outcome:
  match r:
    case Some{s2}:
      Stock.Accepted{s2}
    case None{}:
      Stock.Refused{stock}

# [função nomeada] [função anônima] [casamento de padrões]
# reserve: recusa o pedido nulo; nos demais, procura o produto e tenta reservar.
#
# CASAMENTO DE PADRÕES sobre qty: "0n" é zero (pedido nulo, recusado na hora);
# "1n+q" é qualquer natural maior que zero, e q vale qty - 1.
#
# FUNÇÃO ANÔNIMA: "p => i => same_id(p, i)" é uma função sem nome, escrita
# no ponto em que é usada: recebe um produto p e um identificador i e responde
# se o produto tem esse identificador. Ela é passada a update_where como o
# critério ~matches (função passada como parâmetro). same_id, ao contrário, é
# uma função nomeada, declarada com "def" em src/search.bend.
def reserve(+stock: List<&2, Stock.Product>, +id: Nat, qty: Nat) -> Stock.Outcome:
  match qty:
    case 0n:
      Stock.Refused{stock}
    case 1n+q:
      reserve.fin(stock, Search.update_where(~(p => i => Search.same_id(p, i)), stock, id, 1n+q))
