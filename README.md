# Reserva de estoque em Bend 2

Implementação do artigo *Especificação e Verificação de Propriedades em Funções
Bend 2 sob Alterações Controladas* (UTFPR, SE4FP/CBSoft 2026).

O projeto escreve uma função pura, `reserve`, que reserva unidades de um produto
numa lista de estoque, declara o comportamento exigido como **leis** e prova
cada lei com o verificador do Bend. Depois, uma segunda versão da função, gerada
por uma LLM com uma regressão induzida de propósito, é conferida contra as
mesmas leis, para observar o que os testes unitários detectam e o que as provas
detectam.

> Situação: leis escritas e em revisão. `reserve` ainda é um esboço (`?TODO`) e
> nenhuma lei foi provada.

Convenção: identificadores (tipos, funções, variáveis e nomes das leis) em
inglês; comentários, descrições das leis e documentação em português.

## Bend 2 em um minuto

Bend 2 é uma linguagem funcional pura com tipos dependentes. Além de executar
programas, o compilador confere provas:

- um **`def`** é uma função;
- uma **`law`** (lei) é uma afirmação que precisa valer, por exemplo "para todo
  estoque, a soma das quantidades se conserva";
- uma **prova** é um `def` com o mesmo nome da lei; o verificador só a aceita
  se ela realmente prova a afirmação. Não há busca automática de provas: elas
  são escritas à mão.

`bend arquivo.bend` imprime `ALL PROOFS CHECK` quando todas as leis do arquivo
(e do que ele importa) estão provadas, e `SOME PROOFS FAIL` quando alguma está
aberta ou é falsa, mostrando os termos esperado (`expected`) e obtido
(`observed`).

## Arquivos

| Arquivo | Papel | Quem edita |
|---|---|---|
| `main.bend` | O programa: os tipos `Product` e `Outcome` e a função `reserve`. | Quem implementa (autores na v0, a LLM na v1) |
| `SPEC.bend` | Auxiliares usados só pelas leis, não pelo programa: `Distinct`, `Absent`, `total`, `stock_of`, `sample`. | Congelado após a revisão |
| `LAWS.bend` | Os requisitos, uma `law` cada: propriedades gerais P1-P5 e testes unitários T1-T5. | Congelado após a revisão |
| `PROOF.bend` | Uma prova por lei, chamada `Laws.<lei>`, mais lemas auxiliares. *(ainda não criado)* | Quem implementa |
| `examples/` | Programas pequenos e independentes para aprender como o Bend roda. | Qualquer um |
| `docs/` | Cópias locais do guia do Bend, da biblioteca Base e das páginas consultadas em 22/11/2026. Fora do git; regenere com `bend guide > docs/bend_guide.txt` e `bend base Nat > docs/base_Nat.txt`. | Só referência |
| `logs/` | Ambiente e saídas dos comandos que sustentam os resultados do artigo. | Gerado |

As importações seguem um sentido único: `SPEC.bend` importa `main.bend`;
`LAWS.bend` importa os dois; `PROOF.bend` importa os três. `LAWS.bend` e
`SPEC.bend` não mudam entre versões, então uma versão só passa se cumprir os
mesmos requisitos.

### Tipos (`main.bend`)

```python
type Product is Data:
  Product{id: Nat, available: Nat, reserved: Nat}

type Outcome is Data:
  Accepted{stock: List<&2, Product>}   # o estoque atualizado
  Refused{stock: List<&2, Product>}    # o estoque exatamente como recebido
```

`reserve(stock, id, qty)` aceita quando o produto existe, `qty > 0` e
`qty <= available`: `qty` sai de `available` e entra em `reserved`, e os demais
produtos ficam inalterados. Caso contrário, recusa.

### Leis (`LAWS.bend`)

| ID | Lei | Significado |
|---|---|---|
| P1 | `accept_updates` | Um pedido válido é aceito: o disponível cai `qty` (mesmo até 0), o reservado sobe `qty`, e os produtos antes e depois ficam iguais e na mesma ordem. |
| P2 | `conserve_total` | Para qualquer entrada, a soma de `available + reserved` no estoque devolvido é igual à do estoque recebido. |
| P3 | `refuse_excess` | Pedir mais que o disponível é recusado com o estoque original. |
| P4 | `refuse_zero` | Pedir 0 unidades é recusado com o estoque original. |
| P5 | `refuse_missing` | Pedir um identificador ausente do estoque é recusado com o estoque original. |
| T1-T5 | `t1_...` a `t5_...` | Testes unitários sobre `sample() = [Product{7,10,2}, Product{8,5,0}]`. Nenhum esgota o produto (de propósito). |

### Versões

| Versão | Origem | Esperado pelo desenho |
|---|---|---|
| v0 | Escrita pelos autores | Todos os testes e leis passam |
| v1 | Alteração por LLM: "remover o produto cujo disponível chegar a zero" | T1-T5 continuam passando; as provas de P1 e P2 devem falhar |

Os resultados só são registrados depois de executar as verificações.

## Como rodar

```bash
export PATH="$HOME/.bend/bin:$PATH"       # já está no ~/.bashrc

bend examples/hello.bend                  # executa um programa
bend examples/law_demo.bend --check-only  # confere as provas, sem executar
bend LAWS.bend --check-only               # hoje: 11 TODOs (esboço + 10 leis abertas)
bend PROOF.bend                           # o portão: deve imprimir ALL PROOFS CHECK
bend PROOF.bend --verdict                 # reconfere com o núcleo verificado em Lean
```

O que `bend arquivo.bend` faz depende de `main`:

- sem `main`: só confere;
- `main` devolve um valor: confere, calcula e imprime o valor (ex.: `6n`);
- `main` devolve `IO(...)`: confere, compila e executa.

## Ambiente

| Ferramenta | Versão | Necessária para |
|---|---|---|
| Bend | 2.0.40 (`bend version`) | Tudo |
| Sistema | Ubuntu 22.04.4 no WSL2 | |
| clang | não instalado (14+) | Binários nativos (`bend arquivo.bend -o arquivo`) |
| Lean | não instalado (v4.34.0 via elan) | `--verdict` |

Instalação do Bend: `curl -fsSL https://bend-lang.com/install.sh | sh` (instala
em `~/.bend`). O ambiente registrado está em `logs/ambiente.txt`.

## Referências

- Guia do Bend: `bend guide` (cópia em `docs/bend_guide.txt`)
- https://bend2.dev e https://github.com/bendlang/bend
