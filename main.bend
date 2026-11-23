# stock_reservation: reserva unidades de um produto numa lista de estoque.
# A solicitação é aceita quando o produto existe e a quantidade pedida é
# maior que zero e não ultrapassa a disponível: ela sai do disponível e
# entra no reservado, e os demais produtos ficam inalterados. Caso
# contrário, é recusada e o estoque recebido é devolvido sem alterações.
# LAWS.bend fixa esse comportamento; PROOF.bend prova cada lei.
#
# ESBOÇO: só os tipos e a assinatura de reserve; a implementação vem depois
# da revisão das leis.
#
#   bend main.bend

import Base

type Product is Data:
  Product{id: Nat, available: Nat, reserved: Nat}

type Outcome is Data:
  Accepted{stock: List<&2, Product>}
  Refused{stock: List<&2, Product>}

def reserve(stock: List<&2, Product>, id: Nat, qty: Nat) -> Outcome:
  ?TODO
