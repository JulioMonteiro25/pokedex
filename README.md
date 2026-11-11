# Pokédex

**🔗 Acesse o app: https://juliomonteiro25.github.io/pokedex/**

Pokédex com os dados da [PokéAPI](https://pokeapi.co/): busca por nome ou número, filtro por tipo, status, habilidades, fraquezas e vantagens por tipo, árvore de evoluções com imagens e as 97 Mega Evoluções. Funciona como app no iPhone (tela cheia, ícone de pokébola e uso offline depois do primeiro acesso).

## Idioma (português / inglês)
- O botão **PT / EN** (no topo da lista e na ficha de cada Pokémon) troca o idioma do conteúdo vindo da PokéAPI: descrição, categoria ("Pokémon Rato"), habilidades e condições de evolução. A escolha fica salva no aparelho; na primeira vez o app usa português se o navegador estiver em português.
- As traduções ficam em `docs/pt.json` e **não são oficiais** (a PokéAPI não tem português): nomes de Pokémon e de golpes continuam em inglês. Medidas em milhas, pés e °F foram convertidas para o sistema métrico.
- As Megas usam a descrição e a categoria do Pokémon original.

## Filtro por tipo
- O botão **Tipo ▾** abre uma grade com os 18 tipos e seus ícones. Dá para escolher **mais de um tipo** e combinar como "qualquer um" ou "todos os tipos" (ex.: Fogo + Voador). Cada tipo vira uma etiqueta com ícone e **✕** para remover. Combina com **Mega** e com a busca. Ao filtrar por tipo, as Mega Evoluções daquele tipo aparecem junto, depois dos Pokémon comuns.

## Itens
- A aba **Itens** (barra inferior) lista 142 itens: Pokébolas, Medicamentos, Evolução e Frutas, com busca e uma ficha com o efeito de cada um.
- O botão **Filtrar** abre um painel onde dá para marcar **várias categorias e tipos de item** ao mesmo tempo (ex.: Medicamentos › Reviver, Frutas › Resistência a tipo).
- As imagens vêm do repositório PokeAPI/sprites (arte Dream World, ~90 px). Os efeitos vêm da PokéAPI e podem variar entre gerações; nomes e textos em português **não são oficiais**. O botão PT/EN também vale para os itens.

## Insígnias
- A aba **Insígnias** reúne 68 insígnias de ginásio (Kanto, Johto, Hoenn, Sinnoh, Unova, Kalos, Galar e Paldea), com busca por insígnia, líder, cidade ou tipo e botão **Filtrar** (várias regiões, vários tipos de ginásio e situação: conquistadas ou faltam).
- Cada ficha mostra líder, cidade, tipo e jogos. Dá para **marcar como conquistada**; o progresso fica salvo no próprio aparelho.
- Imagens do repositório PokeAPI/sprites. Os dados foram preenchidos a partir dos jogos principais e podem ter erros; o termo "Insígnia" é uma tradução não oficial.

## Mega Evoluções
- O filtro **Mega** (ao lado de "Todos") mostra só as Megas e combina com o filtro de tipo.
- A busca por nome também encontra as Megas (ex.: "charizard" mostra Charizard, Mega Charizard X e Mega Charizard Y).
- Na ficha do Pokémon, a Mega aparece como último passo da árvore de evoluções; na ficha da Mega valem as mesmas seções (status, habilidades, fraquezas e vantagens).
- As Megas não entram na contagem do "Todos" (1025 Pokémon). Algumas Megas novas ainda estão sem habilidades ou XP base na PokéAPI; o app avisa ou mostra "—".

## Fraquezas e vantagens
Na ficha de cada Pokémon:
- **Fraco contra:** tipos que causam dano dobrado (×2) ou quádruplo (×4), já considerando Pokémon de dois tipos.
- **Forte contra:** tipos que os golpes do tipo do Pokémon atingem com dano dobrado.

O cálculo usa a tabela de tipos embutida no `docs/index.html`, por isso funciona offline e vale para todos os Pokémon.

## Instalar no iPhone
1. Abra https://juliomonteiro25.github.io/pokedex/ no **Safari**.
2. Toque em Compartilhar e depois em **Adicionar à Tela de Início**.
3. Abra pelo ícone da pokébola.

## Estrutura
```
README.md        este arquivo
docs/            o app (é a pasta publicada pelo GitHub Pages)
ferramentas/     scripts PowerShell e a versão antiga para PC
```
- `docs/index.html`, `manifest.webmanifest`, `sw.js`, ícones: o app.
- `docs/insignias.json`: insígnias (dados e imagem em base64), carregado ao abrir a aba Insígnias.
- `docs/itens.json`: itens (nomes e efeitos em PT/EN, imagem em base64), carregado ao abrir a aba Itens.
- `docs/pt.json`: traduções para português (descrições `f`, categorias `g`, habilidades `a` e condições de evolução `e`).
- `docs/data.json`: dados dos 1025 Pokémon (tipos, status, habilidades, evoluções) e, na chave `m`, das 97 Megas.
- `docs/img-0.json` a `img-12.json`: imagens oficiais em pacotes de 80 (base64), carregados sob demanda.
- `docs/img-m0.json`, `img-m1.json`: imagens das Megas (50 por pacote).
- `ferramentas/baixar-dados.ps1`, `montar-dados.ps1`, `montar-pacotes.ps1`: baixam da PokéAPI e geram `data.json` e os pacotes.
- `ferramentas/montar-megas.py`: gera a chave `m` do `data.json` e os pacotes `img-m*.json` a partir dos repositórios [PokeAPI/api-data](https://github.com/PokeAPI/api-data) e [PokeAPI/sprites](https://github.com/PokeAPI/sprites) (precisa de Python e Pillow).
- `ferramentas/servidor-local.ps1`: servidor simples para testar no computador.
- `ferramentas/versao-pc-api.html`: versão antiga, que busca tudo direto na PokéAPI.

A lista vai até o #1025 (9ª geração). Os Pokémon da 10ª geração entram quando houver dados oficiais na PokéAPI.

Pokémon e as imagens são marcas e arte da Nintendo / Game Freak / The Pokémon Company, usados aqui em projeto pessoal e sem fins comerciais.