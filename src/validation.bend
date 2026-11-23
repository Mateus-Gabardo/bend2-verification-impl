# validation: validação e atualização de um único produto.

import Base
import ./stock.bend as Stock

# [função nomeada] [recursão] [casamento de padrões]
# take(n, a): retira n unidades de a. Devolve Some{a - n}, ou None{} quando
# n > a. A recursão tira uma unidade de cada lado até n chegar a zero.
def take(n: Nat, a: Nat) -> Maybe<&2, Nat>:
  match n a:
    case 0n _:
      Some{a}
    case 1n+np 0n:
      None{}
    case 1n+np 1n+ap:
      take(np, ap)

# [função nomeada] [imutabilidade]
# apply_item: monta um produto NOVO com o disponível já descontado e o
# reservado somado; o produto recebido não é alterado
def apply_item(p: Stock.Product, new_available: Nat, qty: Nat) -> Stock.Product:
  match p:
    case Stock.Product{id, available, reserved}:
      Stock.Product{id, new_available, (reserved + qty : Nat)}

# [casamento de padrões] sobre o Maybe devolvido por take. O Bend não aceita
# match sobre o resultado de uma chamada, então o resultado chega aqui como
# parâmetro r.
def reserve_item.fin(p: Stock.Product, qty: Nat, r: Maybe<&2, Nat>) -> Maybe<&2, Stock.Product>:
  match r:
    case Some{left}:
      Some{apply_item(p, left, qty)}
    case None{}:
      None{}

# [função nomeada] validação + atualização de um único produto
def reserve_item(+p: Stock.Product, +qty: Nat) -> Maybe<&2, Stock.Product>:
  match p:
    case Stock.Product{id, available, reserved}:
      reserve_item.fin(p, qty, take(qty, available))
