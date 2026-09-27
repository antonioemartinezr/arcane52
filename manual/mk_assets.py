#!/usr/bin/env python3
"""Genera las imagenes pixel-art del manual de Arcane 52 a partir del cartucho.

Uso:  python3 mk_assets.py            (requiere numpy, pillow, lupa y shrinko8; ver pico8/fuente)
"""
import sys, os, random
HERE = os.path.dirname(os.path.abspath(__file__))
ROOT = os.path.dirname(HERE)
FUENTE = os.path.join(ROOT, 'pico8', 'fuente')
CART = os.path.join(ROOT, 'pico8', 'arcane52.p8')
sys.path.insert(0, FUENTE)
sys.path.insert(0, os.environ.get('SHRINKO8', os.path.expanduser('~/shrinko8')))
import numpy as np
from PIL import Image
from pico import Pico, PAL

OUT = os.path.join(HERE, 'img')
os.makedirs(OUT, exist_ok=True)
SC = [8, 12, 11, 13]      # color de cada escuela (vitalis, aether, grove, ruin)
SD = [2, 1, 3, 2]         # sombra
BAYER = np.array([[0, 8, 2, 10], [12, 4, 14, 6], [3, 11, 1, 9], [15, 7, 13, 5]])

base = Pico(CART, 1)
SHEET = base.sheet
FONT = base.font


class Cv:
    """Lienzo con indices de la paleta PICO-8 (16 = transparente)."""
    def __init__(s, w, h, bg=16):
        s.w, s.h = w, h
        s.a = np.full((h, w), bg, np.int16)

    def pset(s, x, y, c):
        if 0 <= x < s.w and 0 <= y < s.h: s.a[int(y), int(x)] = c

    def rect(s, x0, y0, x1, y1, c, c2=None, lv=0):
        for y in range(max(0, y0), min(s.h, y1 + 1)):
            for x in range(max(0, x0), min(s.w, x1 + 1)):
                s.a[y, x] = c2 if (c2 is not None and BAYER[y % 4][x % 4] < lv) else c

    def frame(s, x0, y0, x1, y1, c):
        for x in range(x0, x1 + 1): s.pset(x, y0, c); s.pset(x, y1, c)
        for y in range(y0, y1 + 1): s.pset(x0, y, c); s.pset(x1, y, c)

    def circ(s, cx, cy, r, c, c2=None, lv=0, ry=None):
        ry = ry or r
        for y in range(cy - ry, cy + ry + 1):
            for x in range(cx - r, cx + r + 1):
                if ((x - cx) / (r + .5)) ** 2 + ((y - cy) / (ry + .5)) ** 2 <= 1:
                    if 0 <= x < s.w and 0 <= y < s.h:
                        s.a[y, x] = c2 if (c2 is not None and BAYER[y % 4][x % 4] < lv) else c

    def line(s, x0, y0, x1, y1, c):
        n = max(abs(x1 - x0), abs(y1 - y0), 1)
        for i in range(n + 1):
            s.pset(round(x0 + (x1 - x0) * i / n), round(y0 + (y1 - y0) * i / n), c)

    def spr(s, sx, sy, w, h, dx, dy, k=1, flip=False, pal=None, outline=None):
        src = SHEET[sy:sy + h, sx:sx + w].astype(np.int16)
        if flip: src = src[:, ::-1]
        if pal:
            m = src.copy()
            for a, b in pal.items(): m[src == a] = b
            src = m
        big = np.kron(src, np.ones((k, k), np.int16))
        mask = big != 0
        if outline is not None:
            pm = np.pad(mask, 1)
            dil = pm.copy()
            dil[1:, :] |= pm[:-1, :]; dil[:-1, :] |= pm[1:, :]; dil[:, 1:] |= pm[:, :-1]; dil[:, :-1] |= pm[:, 1:]
            ys, xs = np.nonzero(dil & ~pm)
            for y, x in zip(ys, xs):
                X, Y = x - 1 + dx, y - 1 + dy
                if 0 <= X < s.w and 0 <= Y < s.h: s.a[Y, X] = outline
        ys, xs = np.nonzero(mask)
        for y, x in zip(ys, xs):
            X, Y = x + dx, y + dy
            if 0 <= X < s.w and 0 <= Y < s.h: s.a[Y, X] = big[y, x]

    def sprn(s, n, dx, dy, k=1, **kw):
        s.spr((n % 16) * 8, (n // 16) * 8, 8, 8, dx, dy, k, **kw)

    def text(s, t, x, y, c, k=1):
        cx = x
        for ch in t.encode():
            g = FONT[(ch // 16) * 6:(ch // 16) * 6 + 6, (ch % 16) * 8:(ch % 16) * 8 + 4]
            ys, xs = np.nonzero(g)
            for yy, xx in zip(ys, xs):
                for a in range(k):
                    for b in range(k): s.pset(cx + xx * k + a, y + yy * k + b, c)
            cx += 4 * k
        return cx

    def paste(s, other, dx, dy):
        m = other.a != 16
        ys, xs = np.nonzero(m)
        for y, x in zip(ys, xs):
            if 0 <= x + dx < s.w and 0 <= y + dy < s.h: s.a[y + dy, x + dx] = other.a[y, x]

    def img(s, k):
        rgba = np.zeros((s.h, s.w, 4), np.uint8)
        m = s.a != 16
        rgba[m, :3] = PAL[s.a[m]]
        rgba[m, 3] = 255
        return Image.fromarray(rgba).resize((s.w * k, s.h * k), Image.NEAREST)

    def save(s, name, k):
        s.img(k).save(os.path.join(OUT, name))


# ------------------------------------------------------------ logo y magos
def logo():
    c = Cv(74, 42)
    c.spr(0, 64, 72, 17, 1, 0)
    c.spr(72, 64, 32, 22, 21, 19)
    c.save('logo.png', 8)
    for i, (n, x) in enumerate((('wiz_b', 0), ('wiz_r', 16))):
        w = Cv(18, 18); w.spr(x, 16, 16, 16, 1, 1, outline=0); w.save(n + '.png', 10)
    for s in range(4):
        p = Cv(8, 8); p.sprn(10 + s, 0, 0); p.save('pip%d.png' % (s + 1), 8)
    for n, name in ((14, 'skull'), (6, 'drop')):
        p = Cv(8, 8); p.sprn(n, 0, 0); p.save(name + '.png', 8)
    p = Cv(8, 8); p.sprn(10, 0, 0, pal={8: 8}); p.save('heart.png', 8)


# ------------------------------------------------------------ cartas reales (renderizadas por el juego)
def real_cards():
    p = Pico(CART, 1); L = p.lua
    def shot(code, name, w=13, h=17, x=10, y=10, k=8):
        p.api_cls(0) if hasattr(p, 'api_cls') else None
        p.scr[:] = 0
        L.execute(code)
        sub = p.scr[y:y + h, x:x + w]
        Image.fromarray(PAL[sub]).resize((w * k, h * k), Image.NEAREST).save(os.path.join(OUT, name))
    for s in range(1, 5):
        for r in range(1, 14):
            c = (s - 1) * 13 + r
            shot('dcard(%d,10,10,true)' % c, 'c_%d_%d.png' % (s, r))
    shot('dcard(1,10,10,false)', 'c_back.png')
    # carta girada (criatura agotada)
    shot('dcard(17,10,10,true,true)', 'c_tapped.png', w=17, h=13, x=8, y=12)


# ------------------------------------------------------------ ilustraciones de cartas ficticias
def art(kind, n, s, seed):
    random.seed(seed)
    W, H = 48, 40
    c = Cv(W, H, 0)
    main, dark = SC[s - 1], SD[s - 1]
    if kind == 'mana': main, dark = 12, 1
    for y in range(H):  # cielo con degradado tramado
        c.rect(0, y, W - 1, y, 0, dark, int(y / H * 15))
    for i in range(14):
        c.pset(random.randrange(W), random.randrange(24), random.choice([7, 6, 13, 5]))
    if kind == 'crea':
        c.circ(24, 19, 15, 0, dark, 6)
        c.circ(24, 19, 11, dark, 0, 3)
        c.rect(0, 33, W - 1, H - 1, dark, 0, 7)
        c.circ(24, 35, 11, 0, None, 0, ry=2)
        c.sprn(n, 8, 3, 4, pal={8: main, 2: dark}, outline=0)
    elif kind == 'spell':
        for a in range(16):  # rayos
            import math
            ang = a * math.pi / 8 + .2
            for r in range(10, 26):
                if (r + a) % 3: c.pset(24 + round(math.cos(ang) * r), 20 + round(math.sin(ang) * r * .8), main if r < 18 else dark)
        c.circ(24, 20, 12, dark, 0, 4)
        c.sprn(n, 8, 4, 4, pal={8: main, 2: dark}, outline=0)
    else:  # mana: gota sobre fuente
        c.rect(0, 31, W - 1, H - 1, 1, 0, 6)
        c.circ(24, 34, 16, 1, 12, 3, ry=3)
        c.circ(24, 34, 10, 12, 7, 2, ry=2)
        c.sprn(n, 8, 0, 4, outline=0)
    for i in range(10):
        x, y = random.randrange(4, W - 4), random.randrange(4, H - 6)
        if c.a[y, x] in (0, dark, 1): c.pset(x, y, random.choice([main, 7, 10]))
    return c


FICT = [  # clave, tipo, sprite, escuela
    ('esp', 'crea', 1, 2), ('esq', 'crea', 2, 4), ('tra', 'crea', 3, 3), ('cab', 'crea', 4, 1), ('dem', 'crea', 5, 4),
    ('des', 'spell', 7, 1), ('egi', 'spell', 8, 2), ('fil', 'spell', 9, 3), ('got', 'mana', 6, 2),
]


def fict_art():
    for i, (k, kind, n, s) in enumerate(FICT):
        art(kind, n, s, i + 3).save('art_%s.png' % k, 8)


# ------------------------------------------------------------ escena: el duelo sobre la mesa
def duel():
    random.seed(52)
    W, H = 240, 150
    c = Cv(W, H, 0)
    for y in range(110):
        c.rect(0, y, W - 1, y, 0, 1, int(y / 110 * 14))
    for i in range(90):
        c.pset(random.randrange(W), random.randrange(90), random.choice([7, 6, 13, 5, 5, 1]))
    c.circ(200, 22, 11, 10); c.circ(205, 18, 10, 0, 1, 1)  # luna creciente
    # montanas
    for x in range(W):
        h1 = 88 - int(14 * abs(((x * 7) % 90) - 45) / 45) - (x % 13 == 0)
        c.rect(x, h1, x, 110, 1, 2, 3)
    # suelo de piedra
    c.rect(0, 108, W - 1, H - 1, 5, 0, 8)
    for y, yy in enumerate((113, 119, 127, 137, 149)):
        c.rect(0, yy, W - 1, yy, 0)
        for x in range((y * 11) % 23, W, 23 + y * 6): c.line(x, yy - 1, x, yy - (2 + y * 2), 0)
    # mesa: tablero + tapete
    c.rect(20, 96, 219, 104, 4)
    c.rect(20, 96, 219, 96, 9)
    c.rect(30, 97, 209, 102, 2, 14, 2)
    c.frame(30, 97, 209, 102, 14)
    c.rect(20, 105, 219, 112, 4, 2, 6)
    c.rect(20, 112, 219, 112, 2)
    for x in (28, 208):
        c.rect(x, 113, x + 4, 140, 4, 2, 5); c.rect(x - 2, 139, x + 6, 141, 2)
    # velas
    for x in (56, 184):
        c.rect(x, 86, x + 3, 95, 7, 6, 4); c.pset(x + 1, 84, 10); c.pset(x + 2, 83, 9); c.pset(x + 1, 85, 9)
    # magos
    c.spr(0, 16, 16, 16, 2, 44, 3, outline=0)
    c.spr(16, 16, 16, 16, 188, 44, 3, flip=True, outline=0)
    # vida sobre cada mago
    for x, hp, col in ((6, '15', 12), (196, '11', 8)):
        c.rect(x, 30, x + 36, 40, 0); c.frame(x, 30, x + 36, 40, col)
        c.sprn(10, x + 4, 32); c.text(hp, x + 14, 32, 7, 1)
    # cartas sobre la mesa (renderizadas del juego)
    p = Pico(CART, 1); L = p.lua
    def card(cid, x, y, tp=False):
        p.scr[:] = 0
        L.execute('dcard(%d,10,10,true%s)' % (cid, ',true' if tp else ''))
        w, h = (17, 13) if tp else (13, 17)
        ox, oy = (8, 12) if tp else (10, 10)
        sub = p.scr[oy:oy + h, ox:ox + w]
        cc = Cv(w, h); cc.a[:] = sub; c.paste(cc, x, y)
    # mana (izq azul, der rojo) y criaturas en juego
    card(19, 60, 79); card(20, 75, 79, True)
    card(4, 95, 79)
    card(46, 132, 79); card(34, 148, 79, True); card(8, 166, 79)
    # criaturas invocadas enfrentadas
    c.sprn(4, 70, 40, 4, pal={8: 12, 2: 1}, outline=0)
    c.sprn(5, 138, 38, 4, flip=True, pal={8: 13, 2: 2}, outline=0)
    for x, st in ((80, '4/4'), (148, '5/5')):
        c.rect(x, 71, x + 13, 77, 0); c.text(st, x + 1, 72, 7)
    # choque de hechizos
    import math
    for i in range(40):
        a = random.random() * math.tau; r = random.random() * 12
        c.pset(120 + round(math.cos(a) * r), 56 + round(math.sin(a) * r * .8), random.choice([10, 9, 7, 14]))
    c.circ(120, 56, 4, 7); c.circ(120, 56, 2, 10)
    c.line(104, 56, 115, 56, 12); c.line(104, 57, 115, 57, 12)
    c.line(125, 55, 136, 55, 14); c.line(125, 56, 136, 56, 14)
    # chispas de los baculos
    for x, y, col in ((34, 50, 10), (205, 50, 14)):
        for i in range(8): c.pset(x + random.randint(-4, 4), y + random.randint(-5, 3), col)
    c.save('duel.png', 4)
    return c


BOT = r'''
function __bot()
 if dlg then dlg=nil end
 if pas then pas=nil end
 if wai and not hq then
  local co=cocreate(function() return aist(view,1) end)
  local ok,a
  repeat ok,a=coresume(co) assert(ok,a) until costatus(co)=="dead"
  hq=a
 end
end
'''


def screenshots():
    p = Pico(CART, 2); p.init(); L = p.lua
    for i in range(150): p.step()
    p.image(4).save(os.path.join(OUT, 'scr_title.png'))
    p.step([4]); [p.step() for i in range(40)]
    p.step([4]); [p.step() for i in range(40)]
    p.step([1]); [p.step() for i in range(10)]
    p.image(4).save(os.path.join(OUT, 'scr_school.png'))
    L.execute('pg=7 go"how"'); [p.step() for i in range(30)]
    p.image(4).save(os.path.join(OUT, 'scr_how.png'))
    # partida con bot hasta tener mesa interesante
    got = {}
    for seed in range(3, 12):
        p = Pico(CART, seed); p.init(); L = p.lua; L.execute(BOT)
        L.execute('startg(1,%d,%d)' % (seed % 4 + 1, (seed + 2) % 4 + 1))
        for f in range(60 * 60 * 8):
            L.execute('__bot()') if not ('main' not in got and L.eval('wai~=nil and g.ph=="main" and g.tn>5 and #g.p[view].c>=2 and #g.p[3-view].c>=2 and #g.p[view].h>=3')) else None
            if 'main' not in got and L.eval('wai~=nil and g.ph=="main" and g.tn>5 and #g.p[view].c>=2 and #g.p[3-view].c>=2 and #g.p[view].h>=3'):
                L.execute('hq=nil')
                for i in range(40): p.step()
                p.image(4).save(os.path.join(OUT, 'scr_main.png')); got['main'] = 1
                continue
            p.step()
            if 'blk' not in got and L.eval('g.ph=="blk" and wai~=nil and g.a~=view and #g.cb.at>=1 and #unt(view)>=1'):
                for i in range(30): p.step()
                p.image(4).save(os.path.join(OUT, 'scr_block.png')); got['blk'] = 1
            if L.eval('ov~=nil') or len(got) == 2: break
        if len(got) == 2: break
    print('capturas', got)


if __name__ == '__main__':
    what = sys.argv[1:] or ['logo', 'real', 'fict', 'duel', 'shots']
    if 'logo' in what: logo()
    if 'real' in what: real_cards()
    if 'fict' in what: fict_art()
    if 'duel' in what: duel()
    if 'shots' in what: screenshots()
    print('ok')
