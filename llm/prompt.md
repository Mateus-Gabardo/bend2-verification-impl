# Alteração por LLM (v1): prompt, resposta e ajustes

- Data: 2026-11-22
- Ferramenta: Claude Code, numa instância isolada que recebeu só este prompt e o
  `main.bend` da v0 (código ainda num único arquivo), sem acesso às leis, às
  provas nem ao repositório
- Modelo: Claude Opus 5.5 (`claude-opus-5-5`)
- Resposta integral: `llm/resposta_bruta.bend`

A regressão é induzida pelo prompt: remover o produto esgotado descarta as
unidades reservadas dele. O estudo não mede a tendência da LLM a errar; usa a
LLM como meio realista de produzir a alteração.

## Prompt

> Você receberá um arquivo em Bend 2 (`main.bend`) com a função `reserve`, que
> reserva unidades de um produto em uma lista de estoque. As leis e os testes
> ficam em outros arquivos, que importam este. Altere somente a implementação
> para que, quando uma reserva aceita deixar o produto com quantidade
> disponível igual a zero, esse produto seja removido da lista retornada. Não
> altere tipos nem assinaturas das funções existentes. Devolva o arquivo
> completo, sem explicações.

## O que a LLM mudou

- acrescentou `keep_if_stocked` e `keep_if_stocked.go`, que descartam o produto
  quando o disponível é zero;
- `put_head` passou a usar `keep_if_stocked(p2, rest)` em vez de `p2 <> rest`.

Tipos e assinaturas existentes não mudaram. O código compilou e executou sem
ajustes.

## Ajustes manuais

- Transporte: a resposta chegou com `<`, `>` e `&` como entidades HTML, que
  foram decodificadas ao gravar `resposta_bruta.bend`.
- Modularização posterior do projeto: a alteração, que só toca a busca, foi
  copiada literalmente para `versions/v1/src/search.bend` (cópia de
  `src/search.bend`), trocando apenas `Product` por `Stock.Product`, o nome do
  tipo importado no módulo.

## Adaptação das provas (`versions/v1/PROOF.bend`)

O `PROOF.bend` da v0 é rejeitado na v1 em `upd_accept` (prova de P1). Para
separar violação de prova a adaptar, foram removidos `upd_accept` e os lemas da
conservação (P2), e P1 e P2 ficaram como `?TODO`; o restante é cópia literal da
v0 e continua aceito. Que P1 e P2 são falsas na v1 é mostrado pelos
contraexemplos `checks/sold_out_p1.bend` e `checks/sold_out_p2.bend`.
