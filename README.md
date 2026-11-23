# Reserva de estoque em Bend 2

Implementação do artigo *Especificação e Verificação de Propriedades em Funções
Bend 2 sob Alterações Controladas* (UTFPR, SE4FP/CBSoft 2026).

**Pergunta de pesquisa:** em que medida as características funcionais do
Bend 2 permitem especificar e verificar propriedades de uma função sujeita a
alterações, e com quais limites?

O estudo escreve uma função pura, `reserve`, declara o comportamento exigido
como **leis** (propriedades gerais P1-P5 e testes unitários T1-T5) e prova cada
lei. Depois, uma LLM altera a busca (v1) com um erro induzido no caso do
produto esgotado, e as mesmas leis são verificadas de novo.

Convenção: identificadores em inglês; comentários e documentação em português.

## Resultado

| Lei | v0 | v1 (LLM) |
|---|---|---|
| T1-T5 testes unitários | aceitas | aceitas |
| P1 atualização correta | provada | **violada** (contraexemplo) |
| P2 conservação do total | provada | **violada** (contraexemplo: total 10 → 5) |
| P3, P4, P5 recusas | provadas | provadas, sem mudar as provas |
| P1 restrita ao produto não esgotado (`checks/blind_spot.bend`) | provada | provada |

A última linha **prova** o ponto cego dos testes: fora do caso esgotado, a v1
satisfaz P1, P3, P4 e P5, que juntas fixam o resultado de todo pedido. Logo, a
v1 só difere da v0 quando o pedido é igual ao disponível, e nenhum teste
unitário que não esgote um produto pode detectar a alteração.

## Como executar a experiência

**1. Instalar o Bend 2** (Linux, macOS ou WSL; o Windows nativo não é suportado):

```bash
curl -fsSL https://bend-lang.com/install.sh | sh
export PATH="$HOME/.bend/bin:$PATH"
bend version                        # bend 2.0.40
```

**2. Baixar o projeto e rodar a versão de referência (v0):**

```bash
git clone https://github.com/Mateus-Gabardo/bend2-verification-impl.git
cd bend2-verification-impl

bend main.bend                      # executa uma reserva de exemplo
bend PROOF.bend                     # confere todas as leis: ALL PROOFS CHECK
```

**3. Montar as duas versões e rodar todas as verificações:**

```bash
sh scripts/run_all.sh               # grava logs/resultados.txt e logs/*.txt
```

O script monta `build/v0` (o projeto) e `build/v1` (o projeto com o módulo de
busca alterado pela LLM). Entre em `build/v1` para repetir os comandos à mão:

```bash
cd build/v1
bend unit_tests.bend                # ALL PROOFS CHECK: os testes T1-T5 passam, mesmo com o erro
bend sold_out_p1.bend               # SOME PROOFS FAIL: o teste do caso esgotado pega o erro
bend PROOF.bend                     # SOME PROOFS FAIL: as leis P1 e P2 pegam o erro
bend blind_spot.bend                # ALL PROOFS CHECK: fora do caso esgotado, v1 = v0
```

Nas mensagens de erro, o Bend chama o lado **esquerdo** da igualdade de
`expected` e o **direito** de `observed`. Em `sold_out_p1.bend`, o esquerdo é o
que a v1 calculou (`[Product{8n, 5n, 0n}]`, sem o produto 7) e o direito é o que
a lei exige (`[Product{7n, 0n, 5n}, Product{8n, 5n, 0n}]`).

## Onde está o código com erro

O erro está em **`versions/v1/src/search.bend`**, entre as marcas
`ALTERAÇÃO DA IA (início)` e `(fim)`, na função `keep_if_stocked.go`:

```python
def keep_if_stocked.go(id: Nat, available: Nat, reserved: Nat, rest: List<&2, Stock.Product>) -> List<&2, Stock.Product>:
  match available:
    case 0n:
      rest                                    # <- o produto esgotado é descartado
    case 1n+ap:
      Stock.Product{id, 1n+ap, reserved} <> rest
```

Quando uma reserva deixa o produto com disponível zero, ele some da lista e leva
junto as unidades que acabou de reservar. Para ver só a alteração em relação à
v0:

```bash
diff src/search.bend versions/v1/src/search.bend
```

**Por que os testes unitários não pegam o erro:** T1-T5 (`checks/unit_tests.bend`)
reservam parte do disponível (por exemplo, 3 das 10 unidades) ou são recusas;
nenhum pede exatamente todo o disponível, que é o único caso que passa pelo
`case 0n`. O teste desse caso (`checks/sold_out_p1.bend`) pega o erro, e as leis
P1 e P2 também, porque valem para qualquer quantidade, inclusive a que esgota o
produto.

## Arquivos

| Arquivo | Papel |
|---|---|
| `src/stock.bend` | tipos `Product{id, available, reserved}` e `Outcome` (`Accepted`/`Refused`) |
| `src/validation.bend` | validação e atualização de um produto: `take`, `apply_item`, `reserve_item` |
| `src/search.bend` | busca na lista: `same_id`, `update_where` (recebe o critério como parâmetro) |
| `src/reserve.bend` | a operação `reserve`, que passa a função anônima à busca |
| `main.bend` | demonstração: chama `reserve` num estoque de exemplo |
| `SPEC.bend` | definições usadas só pelas leis: `Absent`, `total`, `stock_of`, `sample` |
| `LAWS.bend` | as leis P1-P5 e T1-T5; iguais em todas as versões |
| `LEMMAS.bend` | lemas genéricos (aritmética, comparação, `take`) usados pelas provas |
| `PROOF.bend` | uma prova por lei (`Laws.<lei>`) |
| `versions/v1/` | só o que muda na v1: `src/search.bend` (alteração da LLM) e o `PROOF.bend` adaptado |
| `checks/unit_tests.bend` | os testes unitários T1-T5 isolados (passam na v0 e na v1) |
| `checks/sold_out_p1.bend`, `sold_out_p2.bend` | o teste do caso esgotado: passa na v0 e falha na v1 |
| `checks/blind_spot.bend` | a prova do ponto cego: P1 sem esgotar o produto vale na v1 |
| `llm/` | prompt, modelo, data, resposta integral e ajustes da v1 |
| `scripts/run_all.sh` | monta as versões em `build/` e grava os resultados em `logs/` |
| `examples/` | programas pequenos para aprender como o Bend roda |

O código em `src/` tem comentários que mostram, em cada trecho, onde estão o
casamento de padrões, a recursão, a função anônima, a função passada como
parâmetro e o processamento da lista. `build/` é temporária e fica fora do git.

## Ambiente

Bend 2.0.40, Ubuntu 22.04 no WSL2; registro em `logs/ambiente.txt`. `--verdict`
(núcleo verificado em Lean) não foi executado: requer Lean v4.34.0.
