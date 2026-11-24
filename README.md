# Reserva de estoque em Bend 2

Implementação do artigo *Características Funcionais na Verificação de
Propriedades em Bend 2*, de Mateus Gabardo Lemos e Adolfo Gustavo Serra Seca
Neto (UTFPR, SE4FP/CBSoft 2026). O texto do artigo e a apresentação estão em
[bend2-verification](https://github.com/Mateus-Gabardo/bend2-verification).

O artigo investiga em que medida as características funcionais do Bend 2
(funções puras, imutabilidade, casamento de padrões, recursão e funções como
parâmetro) permitem especificar e verificar propriedades de uma função quando
sua implementação é alterada. Este repositório contém o estudo de caso que
sustenta essa análise.

Uma função de reserva de estoque é escrita em Bend 2, e o que ela deve fazer é
declarado como **leis**: cinco propriedades gerais (P1-P5), que valem para
qualquer entrada, e cinco testes unitários (T1-T5), cada um com uma entrada
fixa. Depois, uma IA altera a função com um erro de propósito, e as mesmas leis
são verificadas de novo: os testes continuam passando, mas P1 e P2 falham.

## As duas versões

```
v0/   versão correta
v1/   versão alterada pela IA (com o erro)
llm/  prompt e resposta da IA que gerou a v1
logs/ saídas de todas as verificações
```

Cada pasta é completa e roda sozinha. As duas só diferem em dois arquivos:

```bash
diff v0/src/search.bend v1/src/search.bend   # o erro introduzido pela IA
diff v0/PROOF.bend v1/PROOF.bend             # as provas de P1 e P2, retiradas na v1
```

**O erro** está em `v1/src/search.bend`, entre as marcas `ALTERAÇÃO DA IA`:
quando uma reserva deixa o produto com zero disponível, ele é removido da
lista, e as unidades reservadas somem junto.

## Como executar

Instale o Bend 2 (Linux, macOS ou WSL):

```bash
curl -fsSL https://bend-lang.com/install.sh | sh
export PATH="$HOME/.bend/bin:$PATH"
bend version                        # bend 2.0.40
```

Rode as verificações dentro de cada pasta:

```bash
cd v0
bend PROOF.bend          # ALL PROOFS CHECK: todas as leis valem

cd ../v1
bend unit_tests.bend     # ALL PROOFS CHECK: os testes T1-T5 NÃO pegam o erro
bend sold_out_p1.bend    # SOME PROOFS FAIL: o produto esgotado sumiu da lista
bend sold_out_p2.bend    # SOME PROOFS FAIL: a soma das quantidades caiu de 10 para 5
bend blind_spot.bend     # ALL PROOFS CHECK: fora do caso esgotado, v1 = v0
```

Ou rode tudo de uma vez, nas duas versões, gravando as saídas em `logs/`:

```bash
sh run_all.sh
```

## Resultado

| Lei | v0 | v1 |
|---|---|---|
| T1-T5 (testes unitários) | aceitas | aceitas |
| P1 (atualização) | provada | **falsa** |
| P2 (conservação da soma) | provada | **falsa** |
| P3, P4, P5 (recusas) | provadas | provadas, com as mesmas provas |

Os testes não pegam o erro porque nenhum deles pede todo o disponível de um
produto, que é o único caso em que o erro aparece. P1 e P2 pegam porque valem
para qualquer quantidade.

## Arquivos de cada versão

| Arquivo | O que é |
|---|---|
| `src/` | o programa: tipos (`stock`), validação (`validation`), busca (`search`) e reserva (`reserve`) |
| `main.bend` | exemplo de uso: `bend main.bend` |
| `LAWS.bend` | as leis P1-P5 e T1-T5 (iguais nas duas versões) |
| `SPEC.bend` | funções usadas só para escrever as leis (ex.: soma do estoque) |
| `PROOF.bend` | a prova de cada lei |
| `LEMMAS.bend` | resultados auxiliares usados pelas provas |
| `unit_tests.bend` | só os testes T1-T5 |
| `sold_out_p1.bend`, `sold_out_p2.bend` | o caso que os testes não cobrem: pedir todo o disponível |
| `blind_spot.bend` | prova de que, fora desse caso, a v1 dá o mesmo resultado da v0 |

Ambiente: Bend 2.0.40, Ubuntu 22.04 no WSL2 (`logs/ambiente.txt`).
