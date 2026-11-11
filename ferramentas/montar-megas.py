#!/usr/bin/env python3
"""Acrescenta as Mega Evoluções ao app.

Lê os dados e a arte oficial das Megas dos repositórios públicos da PokéAPI no GitHub
(PokeAPI/api-data e PokeAPI/sprites), grava a chave "m" no docs/data.json e gera os pacotes
de imagens docs/img-m0.json, img-m1.json... (PNG de 280 px em base64, 50 por pacote).
Os dados dos 1025 Pokémon (chaves "p" e "c") não são alterados. Pode rodar de novo à vontade.

Uso:
  python3 ferramentas/montar-megas.py --dados <clone do api-data> --sprites <clone do sprites> [--site docs]
Precisa do Pillow (pip install pillow).
"""
import argparse
import base64
import io
import json
import os
import sys

from PIL import Image

PER = 50        # imagens por pacote (o app usa o mesmo valor: MPER)
SIZE = 280      # lado máximo das imagens, igual ao dos Pokémon comuns


def last(url):
    return int(url.rstrip("/").split("/")[-1])


def rotulo(slug):
    """venusaur-mega -> 'mega venusaur'; charizard-mega-x -> 'mega charizard x';
    meowstic-female-mega -> 'mega meowstic ♀'; tatsugiri-curly-mega -> 'mega tatsugiri (curly)'."""
    t = slug.split("-")
    i = t.index("mega")
    antes, depois = t[:i], t[i + 1:]
    nome = "mega " + antes[0]
    if depois:
        nome += " " + " ".join(depois)
    for extra in antes[1:]:
        nome += {"male": " ♂", "female": " ♀"}.get(extra, " (" + extra + ")")
    return nome


def main():
    ap = argparse.ArgumentParser()
    ap.add_argument("--dados", required=True)
    ap.add_argument("--sprites", required=True)
    ap.add_argument("--site", default=os.path.join(os.path.dirname(os.path.abspath(__file__)), "..", "docs"))
    a = ap.parse_args()

    api = os.path.join(a.dados, "data", "api", "v2", "pokemon")
    arte = os.path.join(a.sprites, "sprites", "pokemon", "other", "official-artwork")
    lista = json.load(open(os.path.join(api, "index.json"), encoding="utf-8"))["results"]
    megas = sorted(((last(r["url"]), r["name"]) for r in lista if "-mega" in r["name"]))

    linhas = []
    for mid, slug in megas:
        p = json.load(open(os.path.join(api, str(mid), "index.json"), encoding="utf-8"))
        tipos = [t["type"]["name"] for t in sorted(p["types"], key=lambda t: t["slot"])]
        abil = [[x["ability"]["name"].replace("-", " "), int(x["is_hidden"])]
                for x in sorted(p["abilities"], key=lambda x: x["slot"])]
        stats = [s["base_stat"] for s in p["stats"]]
        linhas.append([mid, slug, rotulo(slug), last(p["species"]["url"]), tipos,
                       p["height"], p["weight"], p["base_experience"] or 0, stats, abil])
    linhas.sort(key=lambda r: (r[3], r[0]))   # por número da espécie, depois pelo id da forma

    # ---- data.json: acrescenta/substitui só a chave "m" ----
    caminho = os.path.join(a.site, "data.json")
    texto = open(caminho, encoding="utf-8").read().rstrip()
    ini = texto.find(',"m":[')
    if ini != -1:
        texto = texto[:ini] + "}"
    assert texto.endswith("}")
    corpo = ",\n".join(json.dumps(l, ensure_ascii=False, separators=(",", ":")) for l in linhas)
    open(caminho, "w", encoding="utf-8", newline="").write(texto[:-1] + ',"m":[\n' + corpo + "]}")
    print("data.json: %d megas" % len(linhas))

    # ---- pacotes de imagens (mesma ordem das linhas de "m") ----
    imgs = []
    for r in linhas:
        im = Image.open(os.path.join(arte, "%d.png" % r[0])).convert("RGBA")
        k = min(SIZE / im.width, SIZE / im.height)
        im = im.resize((round(im.width * k), round(im.height * k)), Image.LANCZOS)
        buf = io.BytesIO()
        im.save(buf, "PNG", optimize=True)
        imgs.append(base64.b64encode(buf.getvalue()).decode("ascii"))
    antigos = [f for f in os.listdir(a.site) if f.startswith("img-m") and f.endswith(".json")]
    for f in antigos:
        os.remove(os.path.join(a.site, f))
    n = 0
    for i in range(0, len(imgs), PER):
        nome = "img-m%d.json" % (i // PER)
        open(os.path.join(a.site, nome), "w", encoding="utf-8", newline="").write(json.dumps(imgs[i:i + PER], separators=(",", ":")))
        n += 1
        print(nome, os.path.getsize(os.path.join(a.site, nome)) // 1024, "KB")
    print("pacotes:", n)


if __name__ == "__main__":
    sys.exit(main())
