# Pokédex

Pokédex com os dados da [PokéAPI](https://pokeapi.co/): busca por nome ou número, filtro por tipo, status, habilidades, fraquezas e vantagens por tipo e árvore de evoluções com imagens. Funciona como app no iPhone (tela cheia, ícone de pokébola e uso offline depois do primeiro acesso).

## Fraquezas e vantagens
Na ficha de cada Pokémon:
- **Fraco contra:** tipos que causam dano dobrado (×2) ou quádruplo (×4), já considerando Pokémon de dois tipos.
- **Forte contra:** tipos que os golpes do tipo do Pokémon atingem com dano dobrado.

O cálculo usa a tabela de tipos embutida no `docs/index.html`, por isso funciona offline e vale para todos os Pokémon.

## Instalar no iPhone
1. Abra o endereço do GitHub Pages deste repositório no **Safari**.
2. Toque em Compartilhar e depois em **Adicionar à Tela de Início**.
3. Abra pelo ícone da pokébola.

## Estrutura
```
README.md        este arquivo
docs/            o app (é a pasta publicada pelo GitHub Pages)
ferramentas/     scripts PowerShell e a versão antiga para PC
```
- `docs/index.html`, `manifest.webmanifest`, `sw.js`, ícones: o app.
- `docs/data.json`: dados dos 1025 Pokémon (tipos, status, habilidades, evoluções).
- `docs/img-0.json` a `img-12.json`: imagens oficiais em pacotes de 80 (base64), carregados sob demanda.
- `ferramentas/baixar-dados.ps1`, `montar-dados.ps1`, `montar-pacotes.ps1`: baixam da PokéAPI e geram `data.json` e os pacotes.
- `ferramentas/servidor-local.ps1`: servidor simples para testar no computador.
- `ferramentas/versao-pc-api.html`: versão antiga, que busca tudo direto na PokéAPI.

A lista vai até o #1025 (9ª geração). Os Pokémon da 10ª geração entram quando houver dados oficiais na PokéAPI.

Descrições, categorias e habilidades estão em inglês (a PokéAPI não tem português). Pokémon e as imagens são marcas e arte da Nintendo / Game Freak / The Pokémon Company, usados aqui em projeto pessoal e sem fins comerciais.