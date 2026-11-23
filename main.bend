# stock_reservation: reserva unidades de um produto numa lista de estoque.
# A solicitação é aceita quando o produto existe e a quantidade pedida é
# maior que zero e não ultrapassa a disponível: ela sai do disponível e
# entra no reservado, e os demais produtos ficam inalterados. Caso
# contrário, é recusada e o estoque recebido é devolvido sem alterações.
# LAWS.bend fixa esse comportamento; PROOF.bend prova cada lei.
#
#   bend main.bend
#
# saída esperada: src/stock.Accepted{[src/stock.Product{7n, 7n, 5n}, ...]}
#
# O código fica em src/, um módulo por papel:
#   src/stock.bend       tipos Product e Outcome
#   src/validation.bend  validação e atualização de um produto (take, ...)
#   src/search.bend      busca na lista (update_where, ...)
#   src/reserve.bend     a operação reserve
#
# Requisitos da disciplina e onde aparecem (marcados nos comentários):
#   [função nomeada]        take, apply_item, reserve_item, same_id,
#                           update_where, reserve
#   [função anônima]        a lambda p => i => same_id(p, i), em reserve
#   [função como parâmetro] update_where recebe o critério ~matches
#   [casamento de padrões]  match sobre Nat, Maybe, Bool, Product e List
#   [recursão]              take (sobre Nat) e update_where (sobre a lista)
#   [coleção]               update_where percorre e reconstrói a lista
#   [imutabilidade]         nada é alterado no lugar: cada passo devolve
#                           um valor novo, e a recusa devolve o original

import Base
import ./src/stock.bend as Stock
import ./src/reserve.bend as Res

# reserva 3 unidades do produto 7
def main() -> Stock.Outcome:
  Res.reserve([Stock.Product{7n, 10n, 2n}, Stock.Product{8n, 5n, 0n}], 7n, 3n)
