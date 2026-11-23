# search (v1): cópia de src/search.bend com a alteração gerada pela LLM.
# Só este módulo muda; o resto da v1 é idêntico à v0.
# Alteração: put_head descarta o produto cujo disponível chega a zero
# (keep_if_stocked). Resposta original completa em llm/resposta_bruta.bend.

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

# [casamento de padrões] sobre o disponível do produto atualizado: se
# chegou a zero, o produto é descartado; senão, é posto na frente de rest
def keep_if_stocked.go(id: Nat, available: Nat, reserved: Nat, rest: List<&2, Stock.Product>) -> List<&2, Stock.Product>:
  match available:
    case 0n:
      rest
    case 1n+ap:
      Stock.Product{id, 1n+ap, reserved} <> rest

# [imutabilidade] monta uma lista NOVA: com o produto na frente, ou sem
# ele quando seu disponível é zero
def keep_if_stocked(p: Stock.Product, rest: List<&2, Stock.Product>) -> List<&2, Stock.Product>:
  match p:
    case Stock.Product{id, available, reserved}:
      keep_if_stocked.go(id, available, reserved, rest)

# põe na frente da lista o produto atualizado, removendo-o se esgotou
# (ou propaga a recusa)
def put_head(r: Maybe<&2, Stock.Product>, rest: List<&2, Stock.Product>) -> Maybe<&2, List<&2, Stock.Product>>:
  match r:
    case Some{p2}:
      Some{keep_if_stocked(p2, rest)}
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
