# validation: validação e atualização de um único produto.

import Base
import ./stock.bend as Stock

# [função nomeada] [recursão] [casamento de padrões]
# take(n, a): retira n unidades de a. Devolve Some{a - n}, ou None{} se n > a.
#
# CASAMENTO DE PADRÕES: "match n a" olha n e a ao mesmo tempo. Cada "case" é um
# formato possível do par, e vale o primeiro que se encaixa. Um natural é "0n"
# (zero) ou "1n+np" (o sucessor de np, isto é, np + 1); "_" aceita qualquer
# valor. O Bend rejeita um match que não cubra todos os formatos.
#
# RECURSÃO: no terceiro caso, take chama a si mesma com np e ap, que são n e a
# menos uma unidade. Como n diminui a cada chamada, a função chega ao caso 0n
# e termina:
#   take(2, 5) -> take(1, 4) -> take(0, 3) -> Some{3}
#   take(3, 1) -> take(2, 0) -> None{}
def take(n: Nat, a: Nat) -> Maybe<&2, Nat>:
  match n a:
    case 0n _:
      Some{a}
    case 1n+np 0n:
      None{}
    case 1n+np 1n+ap:
      take(np, ap)

# [função nomeada] [casamento de padrões] [imutabilidade]
# apply_item: monta um produto NOVO com o disponível já descontado e o
# reservado somado; o produto recebido p não é alterado.
# O "case Product{id, available, reserved}" abre o registro e dá um nome a
# cada campo, para usá-los no corpo.
def apply_item(p: Stock.Product, new_available: Nat, qty: Nat) -> Stock.Product:
  match p:
    case Stock.Product{id, available, reserved}:
      Stock.Product{id, new_available, (reserved + qty : Nat)}

# [casamento de padrões] sobre Maybe, que é "Some{valor}" (há resultado) ou
# "None{}" (não há). Some{left}: take aceitou e sobraram "left" unidades.
# None{}: take recusou. O Bend não aceita match direto sobre uma chamada, então
# o resultado de take(...) chega a esta função como o parâmetro r.
def reserve_item.fin(p: Stock.Product, qty: Nat, r: Maybe<&2, Nat>) -> Maybe<&2, Stock.Product>:
  match r:
    case Some{left}:
      Some{apply_item(p, left, qty)}
    case None{}:
      None{}

# [função nomeada] validação + atualização de um único produto:
# abre o produto, tenta retirar qty do disponível (take) e, se der, monta o
# produto novo (apply_item).
def reserve_item(+p: Stock.Product, +qty: Nat) -> Maybe<&2, Stock.Product>:
  match p:
    case Stock.Product{id, available, reserved}:
      reserve_item.fin(p, qty, take(qty, available))
