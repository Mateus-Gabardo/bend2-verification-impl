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
unitário que não esgote um produto pode detectar a alteração. T1-T5 são desse
tipo; só um teste do caso esgotado (`checks/sold_out_p1.bend`) a detecta.

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
| `checks/` | `sold_out_p1/p2`: o teste do caso esgotado (contraexemplos na v1); `blind_spot`: a prova do ponto cego |
| `llm/` | prompt, modelo, data, resposta integral e ajustes da v1 |
| `scripts/run_all.sh` | monta as versões em `build/` e grava os resultados em `logs/` |
| `examples/` | programas pequenos para aprender como o Bend roda |

`build/` é temporária e fica fora do git: o script copia nela o projeto da raiz
e, por cima, os arquivos de cada versão.

## Como rodar

```bash
~/.bend/bin/bend main.bend           # executa a reserva de exemplo
~/.bend/bin/bend PROOF.bend          # verifica a v0: ALL PROOFS CHECK
sh scripts/run_all.sh                # v0 e v1, contraexemplos e ponto cego -> logs/

cd build/v1                          # depois do script, a v1 montada
~/.bend/bin/bend PROOF.bend          # SOME PROOFS FAIL em upd_accept (P1)
~/.bend/bin/bend sold_out_p1.bend    # o produto 7 sumiu da lista
~/.bend/bin/bend blind_spot.bend     # ALL PROOFS CHECK: fora do esgotado, igual à v0
```

`bend arquivo.bend` imprime `ALL PROOFS CHECK` quando todas as leis do arquivo
(e do que ele importa) estão provadas, e `SOME PROOFS FAIL` com os termos
`expected` (lado esquerdo da igualdade) e `observed` (lado direito) quando não.

## Ambiente

Bend 2.0.40 (`curl -fsSL https://bend-lang.com/install.sh | sh`), Ubuntu 22.04
no WSL2; registro em `logs/ambiente.txt`. `--verdict` (núcleo verificado em
Lean) não foi executado: requer Lean v4.34.0.
