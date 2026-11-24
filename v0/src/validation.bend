# Validação e atualização de um produto.

import Base
import ./stock.bend as Stock

# retira n de a: Some{a - n}, ou None{} se faltar estoque
# ex.: take(2, 5) -> take(1, 4) -> take(0, 3) -> Some{3}
def take(n: Nat, a: Nat) -> Maybe<&2, Nat>:
  match n a:
    case 0n _:
      Some{a}
    case 1n+np 0n:
      None{}
    case 1n+np 1n+ap:
      take(np, ap)

# cria um produto novo com as quantidades atualizadas
def apply_item(p: Stock.Product, new_available: Nat, qty: Nat) -> Stock.Product:
  match p:
    case Stock.Product{id, available, reserved}:
      Stock.Product{id, new_available, (reserved + qty : Nat)}

# atualiza o produto se take aceitou (Some), senão recusa (None)
def reserve_item.fin(p: Stock.Product, qty: Nat, r: Maybe<&2, Nat>) -> Maybe<&2, Stock.Product>:
  match r:
    case Some{left}:
      Some{apply_item(p, left, qty)}
    case None{}:
      None{}

# tenta reservar qty unidades do produto p
def reserve_item(+p: Stock.Product, +qty: Nat) -> Maybe<&2, Stock.Product>:
  match p:
    case Stock.Product{id, available, reserved}:
      reserve_item.fin(p, qty, take(qty, available))
