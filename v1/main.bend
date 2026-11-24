# Exemplo de uso:  bend main.bend

import Base
import ./src/stock.bend as Stock
import ./src/reserve.bend as Res

# reserva 3 unidades do produto 7
def main() -> Stock.Outcome:
  Res.reserve([Stock.Product{7n, 10n, 2n}, Stock.Product{8n, 5n, 0n}], 7n, 3n)
