# search: busca do produto na lista e reconstrução do estoque.

import Base
import ./stock.bend as Stock
import ./validation.bend as Val

# [função nomeada] [casamento de padrões] critério de seleção: o produto
# tem o identificador pedido? O "case Product{id, ...}" abre o registro, e
# Nat.is_eq compara o id do produto com i.
def same_id(p: Stock.Product, i: Nat) -> Bool:
  match p:
    case Stock.Product{id, available, reserved}:
      Nat.is_eq(id, i)

# [casamento de padrões] sobre Bool. O Bend não tem "if": decide-se com match
# sobre True{} ou False{}. hit é o resultado de matches(p, id); found é a lista
# com p atualizado; skipped é p seguido da busca no restante.
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

# põe na frente da lista o produto atualizado (ou propaga a recusa).
# "p2 <> rest" monta uma lista NOVA com p2 na cabeça; rest não é alterada.
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
# update_where percorre a lista de produtos (processamento da coleção) e
# devolve a lista com o produto procurado atualizado, ou None{} se a reserva
# é recusada (produto inexistente ou quantidade indisponível).
#
# FUNÇÃO COMO PARÂMETRO: ~matches é uma função recebida como argumento
# (Product -> Nat -> Bool). A busca não sabe como o produto é escolhido; só
# chama matches(p, id) em cada produto. O "~" faz o Bend substituir matches
# pelo código recebido já na compilação, e por isso ela pode ser chamada uma
# vez por produto.
#
# CASAMENTO DE PADRÕES: uma lista é vazia, Nil{}, ou é uma cabeça p seguida do
# restante rest, escrita "p <> rest". O "+" permite usar um valor mais de uma vez.
#
# RECURSÃO: se p não é o procurado, a função chama a si mesma com rest, que é
# a lista sem o primeiro produto, até a lista acabar (Nil{} -> None{}):
#   update_where(..., [P7, P8]): P7 não é o 8, mantém P7 e segue por [P8]
#   update_where(..., [P8]):     P8 é o 8, atualiza P8
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
