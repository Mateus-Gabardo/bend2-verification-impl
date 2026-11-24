# Busca do produto na lista: versão v1, alterada pela IA.
# Compare com: diff v0/src/search.bend v1/src/search.bend

import Base
import ./stock.bend as Stock
import ./validation.bend as Val

# o produto p tem o identificador i?
def same_id(p: Stock.Product, i: Nat) -> Bool:
  match p:
    case Stock.Product{id, available, reserved}:
      Nat.is_eq(id, i)

# escolhe o resultado conforme hit (o Bend não tem "if")
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

# ===== ALTERAÇÃO DA IA (início) =====
# ERRO: no caso 0n o produto esgotado é removido da lista,
# junto com as unidades que acabou de reservar
def keep_if_stocked.go(id: Nat, available: Nat, reserved: Nat, rest: List<&2, Stock.Product>) -> List<&2, Stock.Product>:
  match available:
    case 0n:
      rest
    case 1n+ap:
      Stock.Product{id, 1n+ap, reserved} <> rest

# mantém o produto na lista só se ainda houver disponível
def keep_if_stocked(p: Stock.Product, rest: List<&2, Stock.Product>) -> List<&2, Stock.Product>:
  match p:
    case Stock.Product{id, available, reserved}:
      keep_if_stocked.go(id, available, reserved, rest)

# na v0: Some{p2 <> rest}; na v1 passa por keep_if_stocked
def put_head(r: Maybe<&2, Stock.Product>, rest: List<&2, Stock.Product>) -> Maybe<&2, List<&2, Stock.Product>>:
  match r:
    case Some{p2}:
      Some{keep_if_stocked(p2, rest)}
    case None{}:
      None{}

# ===== ALTERAÇÃO DA IA (fim) =====

# mantém o produto p na frente da lista já processada
def keep_head(p: Stock.Product, r: Maybe<&2, List<&2, Stock.Product>>) -> Maybe<&2, List<&2, Stock.Product>>:
  match r:
    case Some{rest2}:
      Some{p <> rest2}
    case None{}:
      None{}

# percorre a lista e reserva no produto escolhido por matches
# (matches: função recebida como parâmetro; recursão sobre a lista)
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
