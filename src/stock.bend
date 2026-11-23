# stock: os tipos de dados do estoque.
#
# Um tipo de dados descreve as formas que um valor pode ter. Product tem uma
# única forma (um registro com três campos); Outcome tem duas (Accepted ou
# Refused). São essas formas que o casamento de padrões (match) examina nos
# outros módulos.

import Base

# um produto: identificador, quantidade disponível e quantidade reservada.
# Nat é o número natural (0, 1, 2, ...): uma quantidade negativa não existe.
type Product is Data:
  Product{id: Nat, available: Nat, reserved: Nat}

# a decisão da reserva, sempre acompanhada do estoque correspondente:
#   Accepted{estoque atualizado}  ou  Refused{estoque exatamente como recebido}
type Outcome is Data:
  Accepted{stock: List<&2, Product>}
  Refused{stock: List<&2, Product>}
