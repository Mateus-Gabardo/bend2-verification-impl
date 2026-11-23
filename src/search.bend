# search: busca do produto na lista e reconstrução do estoque.

import Base
import ./stock.bend as Stock
import ./validation.bend as Val

# [função nomeada] [casamento de padrões] critério de seleção: o produto
# tem o identificador pedido?
def same_id(p: Stock.Product, i: Nat) -> Bool:
  match p:
    case Stock.Product{id, available, reserved}:
      Nat.is_eq(id, i)

# [casamento de padrões] sobre o Bool do critério. hit é o resultado de
# matches(p, id); found é a lista com p atualizado; skipped é p seguido da
# busca no restante.
def update_where.pick(
  found: Maybe<&2, List<&2, Stock.Product>>,
  skipped: Maybe<&2, List<&2, Stock.Product>>,
  hit: Bool
) -> Maybe<&2, List<&2, Stock.Product>>:
  match hit:
    case True{}:
      found
    case False{}:
      skipped

# põe na frente da lista o produto atualizado (ou propaga a recusa)
def put_head(r: Maybe<&2, Stock.Product>, rest: List<&2, Stock.Product>) -> Maybe<&2, List<&2, Stock.Product>>:
  match r:
    case Some{p2}:
      Some{p2 <> rest}
    case None{}:
      None{}

# mantém p na frente da lista já processada (ou propaga a recusa)
def keep_head(p: Stock.Product, r: Maybe<&2, List<&2, Stock.Product>>) -> Maybe<&2, List<&2, Stock.Product>>:
  match r:
    case Some{rest2}:
      Some{p <> rest2}
    case None{}:
      None{}

# [função como parâmetro] [recursão] [coleção] [casamento de padrões]
# update_where percorre o estoque. ~matches é a função recebida como
# parâmetro que decide se um produto é o procurado. No produto escolhido,
# aplica reserve_item; nos demais, mantém o produto e segue pela cauda.
# None{} significa recusa: produto inexistente ou quantidade indisponível.
def update_where(
  ~matches: Stock.Product -> Nat -> Bool,
  stock: List<&2, Stock.Product>,
  +id: Nat,
  +qty: Nat
) -> Maybe<&2, List<&2, Stock.Product>>:
  match stock:
    case Nil{}:
      None{}
    case +p <> +rest:
      update_where.pick(
        put_head(Val.reserve_item(p, qty), rest),
        keep_head(p, update_where(~matches, rest, id, qty)),
        matches(p, id))
