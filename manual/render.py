import asyncio, sys, os
HERE = os.path.dirname(os.path.abspath(__file__))
from playwright.async_api import async_playwright
# comprueba que nada se salga de cada pagina (mm de alto/ancho ocupados)
JS = '''() => { const out=[]; document.querySelectorAll('.page').forEach((p,i)=>{ const r=p.getBoundingClientRect(); let mb=0, mr=0;
 p.querySelectorAll('*').forEach(e=>{ if(e.closest('.pn')) return; const b=e.getBoundingClientRect(); if(b.width==0) return; mb=Math.max(mb,b.bottom-r.top); mr=Math.max(mr,b.right-r.left);});
 out.push([i+1, Math.round(mb/r.height*200), Math.round(mr/r.width*200)]); }); return out; }'''
async def main():
    async with async_playwright() as p:
        b = await p.chromium.launch()
        pg = await b.new_page()
        await pg.goto('file://' + os.path.join(HERE, 'manual.html')); await pg.wait_for_load_state('networkidle')
        await pg.evaluate('document.fonts.ready')
        await pg.emulate_media(media='print')
        print(await pg.evaluate(JS))
        await pg.pdf(path=os.path.join(HERE, 'arcane52_manual.pdf'), prefer_css_page_size=True, print_background=True)
        await b.close()
asyncio.run(main())
