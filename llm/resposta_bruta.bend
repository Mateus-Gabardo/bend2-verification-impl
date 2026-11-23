# stock_reservation: reserva unidades de um produto numa lista de estoque.
# A solicitação é aceita quando o produto existe e a quantidade pedida é
# maior que zero e não ultrapassa a disponível: ela sai do disponível e
# entra no reservado, e os demais produtos ficam inalterados. Se a reserva
# aceita deixar o produto com disponível igual a zero, ele é removido da
# lista retornada. Caso contrário, é recusada e o estoque recebido é
# devolvido sem alterações.
# LAWS.bend fixa esse comportamento; PROOF.bend prova cada lei.
#
# Versão v0 (referência, escrita pelos autores).
#
#   bend main.bend
#
# saída esperada: Accepted{[Product{7n, 7n, 5n}, Product{8n, 5n, 0n}]}
#
# Requisitos da disciplina e onde aparecem (marcados nos comentários):
#   [função nomeada]        take, apply_item, reserve_item, same_id,
#                           update_where, reserve
#   [função anônima]        a lambda p => i => same_id(p, i), em reserve
#   [função como parâmetro] update_where recebe o critério ~matches
#   [casamento de padrões]  match sobre Nat, Maybe, Bool, Product e List
#   [recursão]              take (sobre Nat) e update_where (sobre a lista)
#   [coleção]               update_where percorre e reconstrói a lista
#   [imutabilidade]         nada é alterado no lugar: cada passo devolve
#                           um valor novo, e a recusa devolve o original

import Base

# Tipos
# -----

# um produto: identificador, quantidade disponível e quantidade reservada
type Product is Data:
  Product{id: Nat, available: Nat, reserved: Nat}

# a decisão da reserva, sempre acompanhada do estoque correspondente
type Outcome is Data:
  Accepted{stock: List<&2, Product>}
  Refused{stock: List<&2, Product>}

# Validação
# ---------

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

# Atualização
# -----------

# [função nomeada] [imutabilidade]
# apply_item: monta um produto NOVO com o disponível já descontado e o
# reservado somado; o produto recebido não é alterado
def apply_item(p: Product, new_available: Nat, qty: Nat) -> Product:
  match p:
    case Product{id, available, reserved}:
      Product{id, new_available, (reserved + qty : Nat)}

# [casamento de padrões] sobre o Maybe devolvido por take. O Bend não aceita
# match sobre o resultado de uma chamada, então o resultado chega aqui como
# parâmetro r.
def reserve_item.fin(p: Product, qty: Nat, r: Maybe<&2, Nat>) -> Maybe<&2, Product>:
  match r:
    case Some{left}:
      Some{apply_item(p, left, qty)}
    case None{}:
      None{}

# [função nomeada] validação + atualização de um único produto
def reserve_item(+p: Product, +qty: Nat) -> Maybe<&2, Product>:
  match p:
    case Product{id, available, reserved}:
      reserve_item.fin(p, qty, take(qty, available))

# Busca
# -----

# [função nomeada] [casamento de padrões] critério de seleção: o produto
# tem o identificador pedido?
def same_id(p: Product, i: Nat) -> Bool:
  match p:
    case Product{id, available, reserved}:
      Nat.is_eq(id, i)

# [casamento de padrões] sobre o Bool do critério. hit é o resultado de
# matches(p, id); found é a lista com p atualizado; skipped é p seguido da
# busca no restante.
def update_where.pick(
  found: Maybe<&2, List<&2, Product>>,
  skipped: Maybe<&2, List<&2, Product>>,
  hit: Bool
) -> Maybe<&2, List<&2, Product>>:
  match hit:
    case True{}:
      found
    case False{}:
      skipped

# [casamento de padrões] sobre o disponível do produto atualizado: se
# chegou a zero, o produto é descartado; senão, é posto na frente de rest
def keep_if_stocked.go(id: Nat, available: Nat, reserved: Nat, rest: List<&2, Product>) -> List<&2, Product>:
  match available:
    case 0n:
      rest
    case 1n+ap:
      Product{id, 1n+ap, reserved} <> rest

# [imutabilidade] monta uma lista NOVA: com o produto na frente, ou sem
# ele quando seu disponível é zero
def keep_if_stocked(p: Product, rest: List<&2, Product>) -> List<&2, Product>:
  match p:
    case Product{id, available, reserved}:
      keep_if_stocked.go(id, available, reserved, rest)

# põe na frente da lista o produto atualizado, removendo-o se esgotou
# (ou propaga a recusa)
def put_head(r: Maybe<&2, Product>, rest: List<&2, Product>) -> Maybe<&2, List<&2, Product>>:
  match r:
    case Some{p2}:
      Some{keep_if_stocked(p2, rest)}
    case None{}:
      None{}

# mantém p na frente da lista já processada (ou propaga a recusa)
def keep_head(p: Product, r: Maybe<&2, List<&2, Product>>) -> Maybe<&2, List<&2, Product>>:
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
  ~matches: Product -> Nat -> Bool,
  stock: List<&2, Product>,
  +id: Nat,
  +qty: Nat
) -> Maybe<&2, List<&2, Product>>:
  match stock:
    case Nil{}:
      None{}
    case +p <> +rest:
      update_where.pick(
        put_head(reserve_item(p, qty), rest),
        keep_head(p, update_where(~matches, rest, id, qty)),
        matches(p, id))

# Operação
# --------

# [casamento de padrões] converte o resultado da busca na decisão
def reserve.fin(stock: List<&2, Product>, r: Maybe<&2, List<&2, Product>>) -> Outcome:
  match r:
    case Some{s2}:
      Accepted{s2}
    case None{}:
      Refused{stock}

# [função nomeada] [função anônima] [casamento de padrões]
# reserve: recusa o pedido nulo; nos demais, passa à busca a função anônima
# p => i => same_id(p, i) como critério de seleção
def reserve(+stock: List<&2, Product>, +id: Nat, qty: Nat) -> Outcome:
  match qty:
    case 0n:
      Refused{stock}
    case 1n+q:
      reserve.fin(stock, update_where(~(p => i => same_id(p, i)), stock, id, 1n+q))

def main() -> Outcome:
  reserve([Product{7n, 10n, 2n}, Product{8n, 5n, 0n}], 7n, 3n)
