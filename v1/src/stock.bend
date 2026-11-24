# Tipos do estoque.

import Base

# produto: identificador, disponível e reservado
type Product is Data:
  Product{id: Nat, available: Nat, reserved: Nat}

# resultado: aceita (estoque novo) ou recusada (estoque original)
type Outcome is Data:
  Accepted{stock: List<&2, Product>}
  Refused{stock: List<&2, Product>}
