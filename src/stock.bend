# stock: os tipos de dados do estoque.

import Base

# um produto: identificador, quantidade disponível e quantidade reservada
type Product is Data:
  Product{id: Nat, available: Nat, reserved: Nat}

# a decisão da reserva, sempre acompanhada do estoque correspondente
type Outcome is Data:
  Accepted{stock: List<&2, Product>}
  Refused{stock: List<&2, Product>}
