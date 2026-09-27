pico-8 cartridge // http://www.pico-8.com
version 42
__lua__
-- arcane 52
-- demake pico-8 - reglas v0.2
--$lint: g,foc,sb,dlg,view,pk,bn,hq,wai,lg,back,sel,mode,scr,pj,pas,vis,sm,pg,nm,hj,hf,bsel,ov,hum,hd,fl,dir,think,td,ms,mc,lvl,mt,tr,sh,nh,hot,bk,opt,pt

-- ===== datos =====
sn=split"vitalis,aether,grove,ruin"
sc=split"8,12,11,13"
sd=split"2,1,3,2"
pwd=split"tu criatura +1 defensa,criatura rival -1 def.,tu criatura +1 ataque,1 dano a criatura rival"
rn=split"a,2,3,4,5,6,7,8,9,10,j,q,k"
cc=split"1,2,2,3,3"
ol=split"cancelar atacante,imbloqueable,+0/+2 defensa,+4 vida,+1/+0 ataque,1 dano criatura"
sd2=split"cancelar(1) o imbloq.(1),+0/+2(1) o +4 vida(3),+1/+0(1) o 1 dano(1)"
oc=split"1,1,1,3,1,1"
snd={drw=4,man=5,sum=6,die=11,dmp=10,hp=12,pw=14,atk=8,cls=9,trn=15}
phn={main="invocacion",atk="declara atacantes",blk="te atacan: bloquea",spl="hechizos de combate"}

-- ===== utilidades =====
function cp(o)
 if (type(o)!="table") return o
 local t={} for k,v in pairs(o) do t[k]=cp(v) end
 return t
end
function has(t,v) for _,x in pairs(t) do if (x==v) return true end end
function shuf(t) for i=#t,2,-1 do local j=flr(rnd(i))+1 t[i],t[j]=t[j],t[i] end end
function cpr(s,x,y,c) print(s,x-print(s,0,-99)/2,y,c) end
function opr(s,x,y,c,o)
 for i=-1,1 do for j=-1,1 do print(s,x+i,y+j,o or 0) end end
 print(s,x,y,c)
end
function big(s,x,y,c,o) s="\^w\^t"..s opr(s,x-print(s,0,-99)/2,y,c,o) end
function wt(n) for i=1,n do yield() end end
function rk(c) return (c-1)%13+1 end
function su(c) return flr((c-1)/13)+1 end
function kd(c) local r=rk(c) return r<6 and 1 or r<11 and 2 or 3 end
function ico(c) local r=rk(c) return r<6 and r or r<11 and 6 or r-4 end
function sf(n) sfx(n,3) end
function msg(s,c) ms,mc,mt=s,c or 10,70 end

-- ===== motor de reglas =====
function ev(...) add(g.ev,{...}) end
function newg(s1,s2,f)
 g={dk={},p={},a=f,tn=1,ev={}}
 for i=1,52 do add(g.dk,i) end
 shuf(g.dk)
 for i=1,2 do g.p[i]={i=i,hp=15,s=i==1 and s1 or s2,h={},m={},c={}} end
 for k=1,7 do drw(f) drw(3-f) end
end
function drw(i)
 if (#g.dk==0) return
 local c=deli(g.dk) add(g.p[i].h,c) ev("drw",i,c)
end
function fc(id)
 for p in all(g.p) do for c in all(p.c) do if (c.id==id) return c,p end end
end
function allc()
 local t={} for p in all(g.p) do for c in all(p.c) do add(t,c) end end
 return t
end
function atk(c) return c.a+c.ta end
function def(c) return c.d+c.td-c.dm end
function av(i)
 local p,n=g.p[i],0
 for m in all(p.m) do if (not m.t) n+=1 end
 for c in all(p.c) do if (c.r==1 and not c.t) n+=1 end
 return n
end
function pay(i,n)
 local p=g.p[i]
 for m in all(p.m) do if (n>0 and not m.t) m.t=1 n-=1
 end
 for c in all(p.c) do if (n>0 and c.r==1 and not c.t) c.t=1 n-=1
 end
end
function ctl()
 if (g.w) return
 if (g.pe) return g.pe
 local h=g.ph
 if (h=="main" or h=="atk") return g.a
 if (h=="blk") return 3-g.a
 if (h=="spl") return g.cb.pr
end
function tgts(o)
 if (o==4) return
 if (o<3 and g.ph=="spl") return g.cb.at
 if (o==1) return {}
 local t={} for c in all(allc()) do add(t,c.id) end
 return t
end
function canop(i,o)
 if (not (g.ph=="main" and g.a==i or g.ph=="spl" and g.cb.pr==i) or g.pe) return "ahora no"
 if (av(i)<oc[o]) return "mana insuficiente"
 local t=tgts(o)
 if (t and #t==0) return o==1 and "solo contra atacantes" or "sin objetivos"
end
function canp(i,c)
 local p,k,r=g.p[i],kd(c),rk(c)
 if (g.pe or g.w) return "espera"
 if k==3 then
  local a=canop(i,r*2-21)
  return a and canop(i,r*2-20) and a
 end
 if (g.ph!="main" or g.a!=i) return "solo en tu invocacion"
 if (k==2) return p.mp and "solo 1 mana por turno"
 if (#p.c>4) return "maximo 5 criaturas"
 if (av(i)<cc[r]) return "mana insuficiente"
end
function play(i,c,o,tg)
 local p,k,r=g.p[i],kd(c),rk(c)
 del(p.h,c)
 if k==2 then
  add(p.m,{id=c}) p.mp=1 ev("man",i)
 elseif k==1 then
  pay(i,cc[r])
  add(p.c,{id=c,r=r,a=r,d=r,ta=0,td=0,dm=0,sk=g.tn})
  ev("sum",i)
 else
  pay(i,oc[o]) add(g.dk,c,1)
  local f=tg and fc(tg)
  if o==1 then
   del(g.cb.at,tg) g.cb.bl[tg]=nil ev("f",tg,"cancelada",13,2)
  elseif o==2 then
   f.ub=1 ev("f",tg,"imbloq.",7,13)
   if (g.cb) g.cb.bl[tg]=nil
  elseif o==3 then f.td+=2 ev("f",tg,"+0/+2",11,13)
  elseif o==4 then p.hp+=4 ev("hp",i,4)
  elseif o==5 then f.ta+=1 ev("f",tg,"+1/+0",9,13)
  else f.dm+=1 ev("f",tg,"-1",8,9) chkd() end
  if (g.ph=="spl") g.cb.ps=0 g.cb.pr=3-i
 end
 chkw()
 if (not g.w and su(c)==p.s and not p.pu and #ptg(i)>0) g.pe=i
end
function chkd()
 for p in all(g.p) do
  for c in all(p.c) do
   if def(c)<1 then
    del(p.c,c) add(g.dk,c.id,1)
    if (g.cb) del(g.cb.at,c.id)
    ev("die",c.id)
   end
  end
 end
end
function chkw()
 for p in all(g.p) do if (p.hp<1 and not g.w) g.w=3-p.i
 end
end
function ptg(i)
 local t={} for c in all(g.p[g.p[i].s%2==1 and i or 3-i].c) do add(t,c.id) end
 return t
end
function upw(tg)
 local i=g.pe local s,f=g.p[i].s,fc(tg)
 if s==1 then f.d+=1
 elseif s==2 then f.d-=1
 elseif s==3 then f.a+=1
 else f.dm+=1 end
 ev("f",tg,split"+1 def,-1 def,+1 atq,1 dano"[s],sc[s],s%2==1 and 13 or 9)
 g.p[i].pu=1 g.pe=nil ev("pw",i) chkd()
end
function cana(c) return not c.t and c.sk!=g.tn end
function unt(i) local t={} for c in all(g.p[i].c) do if (not c.t) add(t,c) end return t end
function datk(ids)
 if (#ids==0) return endt()
 local ok for id in all(ids) do local c=fc(id) c.t=1 ok=ok or not c.ub end
 g.cb={at=ids,bl={},pr=g.a,ps=0}
 ev"atk"
 g.ph=(ok and #unt(3-g.a)>0) and "blk" or "spl"
end
function dblk(bl)
 g.cb.bl=bl g.ph="spl"
 ev("blk",next(bl))
end
function pass()
 local b=g.cb b.ps+=1 b.pr=3-b.pr
 if (b.ps>1) g.ph="res"
end
function clash(aid)
 local b,a=g.cb,fc(aid)
 if (not a or not has(b.at,aid)) return
 del(b.at,aid)
 local bid=b.bl[aid]
 if bid then
  local d=fc(bid)
  if d then
   local x,y=atk(a),atk(d) d.dm+=x a.dm+=y
   ev("cls",aid,bid,x,y) chkd()
  end
 else
  local x=atk(a) g.p[3-g.a].hp-=x ev("dmp",3-g.a,x) chkw()
 end
end
function resall() if g.cb then for id in all(cp(g.cb.at)) do clash(id) end end
end
function endt()
 for p in all(g.p) do
  for c in all(p.c) do c.ta,c.td,c.dm,c.ub=0,0,0 end
 end
 g.cb,g.pe=nil g.a=3-g.a g.tn+=1
 sturn()
end
function sturn()
 local p=g.p[g.a]
 for m in all(p.m) do m.t=nil end
 for c in all(p.c) do c.t=nil end
 p.mp,g.ph=nil,"main"
 ev("trn",g.a) drw(g.a)
end

-- ===== ia =====
function val(c) return c.a+c.d end
function hsc(h) return h<1 and -200 or h+min(h-5,0)*1.5 end
function evl(i)
 if (g.w) return g.w==i and 999 or -999
 local m,o=g.p[i],g.p[3-i]
 local r=(hsc(m.hp)-hsc(o.hp))*1.2+(#m.h-#o.h)*.6+(#m.m-#o.m)*.5
 for c in all(m.c) do r+=val(c) end
 for c in all(o.c) do r-=val(c) end
 return r
end
function sim(f,i)
 local o=g g=cp(o) g.ev={} f()
 local r=evl(i) g=o return r
end
function outc(at,bl)
 local dm,v,h=0,0,g.p[3-g.a].hp
 for aid in all(at) do
  local a,bid=fc(aid),bl[aid]
  if bid then
   local b=fc(bid)
   if (def(b)<=atk(a)) v-=val(b)
   if (def(a)<=atk(b)) v+=val(a)
  else dm+=atk(a) end
 end
 if (dm>=h) return -999
 return (hsc(h-dm)-hsc(h))*1.2+v
end
function bblk(at,rz)
 local bs,best,cur,used,n,bq=-9999,{},{},{},0,{}
 for id in all(at) do if (not fc(id).ub) add(bq,id)
 end
 local function rec(k)
  if (n>150) return
  if k>#bq then
   n+=1 if (n%30==0) yield()
   local s=outc(at,cur)+rnd(rz)
   if (s>bs) bs=s best=cp(cur)
   return
  end
  rec(k+1)
  for d in all(unt(3-g.a)) do
   if not used[d.id] then
    used[d.id]=1 cur[bq[k]]=d.id rec(k+1) cur[bq[k]]=nil used[d.id]=nil
   end
  end
 end
 rec(1)
 return best,bs
end
function batk()
 local r,best,bs={},{},.01
 for c in all(g.p[g.a].c) do if (cana(c)) add(r,c.id)
 end
 for m=1,2^#r-1 do
  local ids={}
  for k=1,#r do if (flr(m/2^(k-1))%2==1) add(ids,r[k])
  end
  local _,s=bblk(ids,0)
  s=-s+#ids*.05
  if (s>bs) bs=s best=ids
 end
 return best
end
function dpw(i)
 local b,bv=nil,-1
 for id in all(ptg(i)) do
  local c=fc(id) local v=val(c)+(def(c)<2 and 9 or 0)
  if (v>bv) b,bv=id,v
 end
 if (g.p[i].s<4 or bv>8) return b,b
end
function bspl(i,cmb,th)
 local hp=g.p[i].hp
 local best,bs=nil,sim(function() if (cmb) resall()
 end,i)+th
 for c in all(g.p[i].h) do
  if kd(c)==3 then
   for o=rk(c)*2-21,rk(c)*2-20 do
    if not canop(i,o) and (cmb or o==6 or o==4 and hp<11) then
     for t in all(tgts(o) or {0}) do
      local tg=t>0 and t or nil
      local s=sim(function()
       play(i,c,o,tg)
       if g.pe==i then
        local u,x=dpw(i)
        if (u) upw(x)
        g.pe=nil
       end
       if (cmb) resall()
      end,i)
      if (s>bs) bs=s best={k="sp",id=c,o=o,tg=tg}
      yield()
     end
    end
   end
  end
 end
 return best
end
function aist(i,lv)
 local p=g.p[i]
 if g.pe==i then local u,t=dpw(i) return {k="pw",u=u,tg=t} end
 if g.ph=="main" then
  local m,b
  for c in all(p.h) do
   if (kd(c)==2 and not p.mp and (not m or su(c)==p.s)) m=c
   if (kd(c)==1 and not canp(i,c) and (not b or rk(c)>rk(b))) b=c
  end
  if (m or b) return {k="c",id=m or b}
  return bspl(i,false,lv<1 and 2 or .6) or {k="goat"}
 end
 if (g.ph=="atk") return {k="atk",ids=batk()}
 if (g.ph=="blk") return {k="blk",bl=(bblk(g.cb.at,lv<1 and 4 or 0))}
 if (lv<1 and rnd()<.5) return {k="pass"}
 return bspl(i,true,.8) or {k="pass"}
end

-- ===== efectos =====
function burst(x,y,n,cs,sp,gr)
 for k=1,n do
  local a,v=rnd(),(.3+rnd())*(sp or 1.5)
  add(pt,{x=x,y=y,dx=cos(a)*v,dy=sin(a)*v-.5,l=15+rnd(15),c=cs[k%#cs+1],g=gr or .08})
 end
end
fts={}
function flt(x,y,s,c) add(fts,{x=x,y=y,s=s,c=c,t=0}) end
function cpos(id) local v=vis[id] or {x=58,y=56} return v.x+6,v.y+8 end
function hpos(i) return 8,i==view and 122 or 1 end
function rowy(i) return i==view and 51 or 8 end
function fx()
 local w=0
 for e in all(g.ev) do
  local t,a,b,c,d=unpack(e)
  local n,x,y=snd[t] or d,cpos(a)
  if (n) sf(n)
  if t=="f" then
   if (a<0) x,y=8,rowy(-a)+8
   flt(x,y-10,b,c) burst(x,y,8,{c,7})
  elseif t=="man" then burst(7,rowy(a)+8,12,{12,7},1,-.05)
  elseif t=="sum" then burst(8+#g.p[a].c*15,rowy(a)+14,14,{7,15,10},1.2) sh=2
  elseif t=="die" then burst(x,y,30,{sc[su(a)],7,15},2,.12) w=10
  elseif t=="dmp" or t=="hp" then
   x,y=hpos(a) local k=t=="hp" and 11 or 8
   flt(x+14,y+(a==view and -8 or 8),(k>8 and "+" or "-")..b,k) burst(x,y+3,14,{k,7},1.2)
   if (k<9) sh,fl,w=5,6,15
  elseif t=="pw" then local s=g.p[a].s bn={sn[s],sc[s],0,pwd[s]} w=40
  elseif t=="blk" then msg(a and "bloqueos declarados" or "sin bloqueos",a and 9 or 6) if (a) sf(17)
  elseif t=="cls" then
   local u,v=cpos(b) flt(u,v-10,"-"..c,8) flt(x,y-10,"-"..d,8)
   burst((x+u)/2,(y+v)/2,16,{10,9,7},2) sh=3
  elseif t=="trn" then
   local me=a==view
   bn={mode==2 and "turno j"..a or me and "tu turno" or "turno cpu",me and 12 or 8,0,"turno "..g.tn}
   w=50
  end
 end
 g.ev={}
 return w
end
function drawfx()
 for p in all(pt) do
  p.x+=p.dx p.y+=p.dy p.dy+=p.g p.l-=1
  if (p.l<0) del(pt,p)
  pset(p.x,p.y,p.c)
 end
 for f in all(fts) do
  f.t+=1 opr(f.s,f.x-#f.s*2,f.y-min(f.t,20)/2,f.c)
  if (f.t>40) del(fts,f)
 end
end

-- ===== director (corrutina) =====
function doact(i,a)
 local k=a.k
 if k=="sp" then
  local s=sc[su(a.id)]
  sf(7) bn={ol[a.o],s,0,nm[i].." lanza "..rn[rk(a.id)]} wt(30)
  if (a.tg) local x,y=cpos(a.tg) burst(x,y,24,{s,7,10},2,0) sf(20)
  play(i,a.id,a.o,a.tg)
 elseif k=="pw" then
  if a.u then upw(a.tg) else g.pe=nil sf(2) msg("poder reservado",13) end
 elseif k=="goat" then g.ph="atk"
 elseif k=="atk" then
  msg(#a.ids>0 and "ataque con "..#a.ids or "sin ataque",8) datk(a.ids)
 elseif k=="blk" then dblk(a.bl)
 elseif k=="pass" then pass() if (not hum[i]) msg("la cpu pasa",6)
 elseif k=="end" then endt()
 else play(i,a.id) end
 wt(fx()+12)
end
function combat()
 wt(8)
 for aid in all(cp(g.cb.at)) do
  if fc(aid) then
   local bid,x,y=g.cb.bl[aid]
   if bid then x,y=cpos(fc(bid) and bid or aid)
   else x,y=hpos(3-g.a) y+=3-g.a==view and -8 or 8 end
   lg={aid,x,y,0} sf(8) wt(5) clash(aid) wt(fx()+9) lg=nil wt(6)
   if (g.w) return
  end
 end
 wt(6) endt()
end
function hascast(i)
 for c in all(g.p[i].h) do if (kd(c)==3 and not canp(i,c)) return true
 end
end
function director()
 while true do
  wt(fx())
  if g.w then
   wt(25) ov=0 music(-1) sf((mode==2 or g.w==1) and 21 or 22)
   return
  end
  if g.ph=="res" then combat()
  else
   local c=ctl()
   if hum[c] then
    if mode==2 and view!=c then pas=c repeat yield() until not pas view=c end
    if g.ph=="spl" and not g.pe and not hascast(c) then
     msg("sin hechizos: pasas",6) wt(16) pass()
    else
     tips() prep(c) hq=nil wai=1
     repeat yield() until hq
     wai=nil doact(c,hq)
    end
   else
    wt(16) doact(c,aist(c,lvl))
   end
  end
 end
end
tt=split("bienvenido a arcane 52! soy el archimago y te guiare en tu primer duelo.|objetivo: baja la vida de la hechicera de 15 a 0.|6 a 10 son mana, a a 5 son criaturas y j q k son hechizos.|flechas para elegir. 🅾️ acepta y ❎ vuelve atras.#jugaste una carta de tu escuela! puedes activar su poder una vez por partida, o reservarlo.#te atacan! elige una criatura tuya y pulsa 🅾️ para bloquear. repite para cambiar de atacante.#ventana de hechizos: antes del dano puedes lanzar j q o k. si no, pulsa pasar.#juega 1 carta de mana (6-10) por turno y luego invoca criaturas (a-5). al pagar, el mana se gira.|las criaturas atacan desde tu siguiente turno: pulsa combate y elige atacantes.","#",false)
function say(s) dlg={split(s,"|",false),1,0} repeat yield() until not dlg end
function tips()
 if (mode<3) return
 local k=td[1] and (g.pe and 2 or ({blk=3,spl=4,main=5})[g.ph]) or 1
 if (k and not td[k]) td[k]=1 say(tt[k])
end
function prep(i)
 sb,sel,bsel=nil,{},{}
 local p=g.p[i]
 foc=g.ph=="blk" and unt(i)[1] and unt(i)[1].id or "m1"
 if g.ph=="main" or g.ph=="spl" then for c in all(p.h) do if not canp(i,c) then foc=c end end end
end

-- ===== partida =====
function startg(m,s1,s2)
 mode,scr,hum,lvl=m,"game",{true,m==2},m==3 and 0 or 1
 local f=flr(rnd(2))+1
 newg(s1,s2,f)
 view,nm=m==2 and f or 1,m==2 and split"j1,j2" or split"tu,cpu"
 vis,hd,sel,bsel,td,pt={},{15,15},{},{},{},{}
 for k,e in pairs(g.ev) do vis[e[3]]={x=1,y=33,d=k*3} end
 g.ev={} sturn()
 ov,dlg,pas,sb,bn,lg,wai=nil
 tr,dir=16,cocreate(director)
 if (opt[1]) music(2,500,7)
end

-- ===== interfaz =====
hot,nh={},{}
function hs(id,x,y,w,h,f) add(nh,{id=id,x=x,y=y,w=w,h=h,f=f}) end
function hget(id) for h in all(hot) do if (h.id==id) return h end end
function nav(b)
 local c=hget(foc) if (not c) return
 local cx,cy,bd,bh=c.x+c.w/2,c.y+c.h/2,999
 for h in all(hot) do
  local dx,dy=h.x+h.w/2-cx,h.y+h.h/2-cy
  local q=({-dx,dx,-dy,dy})[b+1]
  local p=q+(b<2 and abs(dy) or abs(dx))*2.2
  if (h!=c and q>1 and p<bd) bd=p bh=h
 end
 if (bh) foc=bh.id sf(0)
end
function box(x,y,w,h,c)
 rectfill(x,y,x+w,y+h,0) rect(x,y,x+w,y+h,c)
end
function menu(it,x,y,dy)
 for k,m in pairs(it) do
  local id,yy="m"..k,y+k*dy
  cpr(m[1],x,yy,m[3] or foc==id and 10 or 7)
  if (foc==id) spr(22,x-print(m[1],0,-99)/2-8+t()*4%2,yy)
  hs(id,x-40,yy-2,80,dy,m[2])
 end
end

-- cartas
function dcard(c,x,y,f,tp)
 local w,h=12,16
 if (tp) w,h=16,12 x-=2 y+=2
 rectfill(x,y,x+w,y+h,15)
 if f then
  local k,s=kd(c),su(c)
  rectfill(x,y,x+w,y+h,k-1) rect(x,y,x+w,y+h,({15,12,14})[k])
  print(rn[rk(c)],x+2,y+2,rk(c)==10 and sc[s] or 7)
  if (rk(c)!=10) spr(9+s,x+7,y+2)
  pal(8,sc[s]) pal(2,sd[s])
  spr(ico(c),x+w-9,y+h-8) pal()
 else
  fillp(0xa5a5) rectfill(x+1,y+1,x+w-1,y+h-1,0x12) fillp()
  rect(x+3,y+3,x+w-3,y+h-3,9)
 end
end
function lay()
 local l={}
 local function a(i,x,y,f,p,c,h) add(l,{i=i,x=x,y=y,f=f,p=p,c=c,h=h}) end
 for i=1,2 do
  local p,y=g.p[i],rowy(i)
  for k,m in pairs(p.m) do a(m.id,1,y,1,k<#p.m,m) end
  for k,c in pairs(p.c) do
   a(c.id,2+k*15,y,1,nil,c)
  end
  local n=#p.h
  for k,c in pairs(p.h) do
   if i==view then
    local s=min(14,112/max(n-1,1))
    a(c,58-(n-1)*s/2+(k-1)*s,foc==c and wai and 73 or 77,1,nil,nil,1)
   else a(c,58-(n-1)*3+(k-1)*6,-12) end
  end
 end
 for k,c in pairs(g.dk) do a(c,1,33,nil,k<#g.dk) end
 return l
end
function drcards(l)
 local mv={}
 for e in all(l) do
  local v=vis[e.i] or {x=1,y=33}
  vis[e.i]=v
  if v.d then v.d-=1 if (v.d<1) v.d=nil sf(4)
  else
   v.x+=(e.x-v.x)/4 v.y+=(e.y-v.y)/4
   if abs(e.x-v.x)+abs(e.y-v.y)>2 or e.h and foc==e.i then add(mv,e) elseif not e.p then dc1(e) end
  end
 end
 foreach(mv,dc1)
end
function dc1(e)
 local i,c,v=e.i,e.c,vis[e.i]
 local x,y,o=v.x,v.y
 if lg and lg[1]==i then
  lg[4]+=1 local k=min(lg[4]/6,max(0,2.3-lg[4]/7))
  x+=(lg[2]-6-x)*.7*k y+=(lg[3]-8-y)*.7*k
 end
 if (c and c.a and (g.cb and has(g.cb.at,i) or sel[i])) y+=e.y<45 and 3 or -3
 dcard(i,x,y,e.f,c and c.a and c.t)
 if c then
  if c.a then
   print(atk(c).."/"..def(c),x+1,y+18,c.dm>0 and 8 or c.ta+c.td+c.a+c.d>2*c.r and 11 or 7)
   if (c.sk==g.tn) spr(20,x+8,y-3+sin(t())*1.5)
   if (c.ub and bk) o=7
   if (g.cb and has(g.cb.at,i)) o=8
   if (sel[i]) o=9
   if (sb and sb.l and has(sb.l,i)) o=bk and 14 or 7
  elseif c.t then fillp(0xa5a5.8) rectfill(x,y,x+12,y+16,0) fillp() end
 end
 if (foc==i and wai) o=bk and 10 or 9 spr(21,x+4,y-5+sin(t()*2))
 if (o) rect(x-1,y-1,x+13,y+17,o)
end
function bline(b,a,c)
 if fc(a) and fc(b) then
  local x,y=cpos(b) local u,v=cpos(a)
  fillp(0x5a5a.8) line(x,y,u,v,c) fillp() circfill(u,v,1,c)
 end
end

function board(i)
 local p,y,v=g.p[i],rowy(i),i==view
 fillp(0xa5a5) rectfill(0,y-1,127,y+23,v and 0x20 or 0x30) fillp()
 for k=1,5 do rect(2+k*15,y,14+k*15,y+16,v and 2 or 3) end
 rect(1,y,13,y+16,5)
 local s,f=p.s,0
 spr(9+s,92,y+1) print(sn[s],98,y+1,sc[s])
 print("poder "..(p.pu and "-" or "+"),92,y+8,g.pe==i and bk and 10 or 6)
 for m in all(p.m) do if (not m.t) f+=1 end
 print(f.."/"..#p.m,1,y+18,12)
end
function hud(i,y)
 hd[i]+=mid(-.2,g.p[i].hp-hd[i],.2)
 local v=flr(hd[i]+.5)
 print("♥"..v,1,y,v<6 and bk and 7 or 8)
 print(nm[i],20,y,g.a==i and 10 or 6)
end
function info(c)
 local k,r,f=kd(c),rk(c),fc(c)
 local x=print(rn[r],1,95,7)
 spr(9+su(c),x,95)
 print(k==2 and "mana: da 1 al girarse"
  or k==1 and "criatura "..(f and atk(f).."/"..def(f) or r.."/"..r.." coste "..cc[r])
  or sd2[r-10],x+7,95,15)
end
function hint(i)
 if (sb and sb.l) return "elige un objetivo"
 for c in all(g.p[i].h) do if (not canp(i,c)) return "consejo: puedes jugar "..rn[rk(c)]
 end
 return g.ph=="blk" and "🅾️ sobre tu criatura" or ""
end

function drgame()
 local v=view
 cls() stars()
 board(3-v) board(v)
 fillp(0x5a5a) rectfill(0,32,127,49,g.a==v and 0x10 or 0x20) fillp()
 rect(1,33,13,49,5)
 hud(3-v,1) hud(v,122) print("t"..g.tn,110,1,13)
 local i=ctl()
 if mt>0 then mt-=1 cpr(ms,64,35,mc)
 elseif i and hum[i] then cpr(g.pe and "poder de "..sn[g.p[i].s] or phn[g.ph],64,35,12) end
 if (wai and opt[2]) cpr(hint(i),64,42,13)
 local l=lay()
 if (wai) uihot(l)
 drcards(l) print(#g.dk,3,43,7)
 if g.ph=="blk" then for b,a in pairs(bsel) do bline(b,a,bk and 10 or 9) end end
 if g.cb then for a,b in pairs(g.cb.bl) do bline(b,a,9) end end
 if (wai and type(foc)=="number" and not sb) info(foc)
 drawfx() overlays()
end

function uihot(l)
 local i,ph=view,g.ph
 local p=g.p[i]
 if sb and sb.l then
  for e in all(l) do
   if e.c and has(sb.l,e.i) then hs(e.i,e.x,e.y,13,17,function() sb.a.tg=e.i hq=sb.a sb=nil end) end
  end
  return
 end
 if (sb or g.pe) return
 for e in all(l) do
  local c,cr=e.i,e.c
  if e.h and (ph=="main" or ph=="spl") then
   hs(c,e.x,77,13,17,function()
    local r=canp(i,c)
    if (r) sf(3) msg(r,8) return
    if (kd(c)==3) sb={c=c} foc="m1" sf(1) return
    hq={k="c",id=c}
   end)
  end
  if cr and has(p.c,cr) then
   if ph=="atk" then hs(c,e.x,e.y,13,17,function() if cana(cr) then sel[c]=not sel[c] or nil sf(8) else sf(3) end end) end
   if ph=="blk" and not cr.t then
    hs(c,e.x,e.y,13,17,function()
     local at,k=g.cb.at,0
     for j=1,#at do if (at[j]==bsel[c]) k=j
     end
     bsel[c]=nil
     repeat k=(k+1)%(#at+1) until k==0 or not fc(at[k]).ub and not has(bsel,at[k])
     bsel[c]=at[k] sf(17)
    end)
   end
  end
 end
 local it
 if ph=="main" then
  local r for c in all(p.c) do if (cana(c)) r=1 end
  it={{"combate",function() if r then g.ph="atk" sel={} foc=nil sf(1) else sf(3) msg("nadie puede atacar",8) end end,not r and 5},{"fin de turno",function() hq={k="end"} end}}
 elseif ph=="atk" then
  local ids={} for k in pairs(sel) do add(ids,k) end
  it={{#ids>0 and "atacar con "..#ids or "no atacar",function() hq={k="atk",ids=ids} sel={} end},{"todas",function() for c in all(p.c) do if (cana(c)) sel[c.id]=1 end end}}
 elseif ph=="blk" then
  local bl,n={},0 for b,a in pairs(bsel) do bl[a]=b n+=1 end
  it={{n>0 and "bloquear con "..n or "sin bloqueos",function() hq={k="blk",bl=bl} bsel={} end}}
 else it={{"pasar",function() hq={k="pass"} end}} end
 menu(it,64,94,9)
end
function gback()
 if (dlg) dlg=nil return
 if (not wai) return
 sf(2)
 if sb then
  if sb.l and sb.a.o then sb={c=sb.a.id} foc="m1" else sb=nil end
 elseif g.pe==view then hq={k="pw"}
 elseif g.ph=="atk" then g.ph="main" sel={} prep(view) end
end

function overlays()
 local v=view
 if sb and not sb.l and wai then
  local c=sb.c local r,it=rk(c),{}
  box(14,50,100,40,7) cpr(rn[r].." - elige efecto",64,54,10)
  for o=r*2-21,r*2-20 do
   local e=canop(v,o)
   add(it,{ol[o].." ("..oc[o]..")",function()
    if (e) sf(3) msg(e,8) return
    local tl=tgts(o)
    if (not tl) hq={k="sp",id=c,o=o} sb=nil return
    sb={l=tl,a={k="sp",id=c,o=o}} foc=tl[1] sf(1)
   end,e and 5})
  end
  add(it,{"cancelar",gback})
  menu(it,64,55,9)
 elseif g.pe==v and wai and not sb then
  local s=g.p[v].s
  box(14,50,100,40,sc[s]) cpr("poder de "..sn[s],64,54,sc[s]) cpr(pwd[s],64,61,7)
  menu({{"activar",function() sb={l=ptg(v),a={k="pw",u=1}} foc=sb.l[1] sf(1) end},{"reservar",gback}},64,62,9)
 end
 if bn then
  local k=bn[3] bn[3]+=1
  local x=k<8 and (k-8)*16 or max(0,k-40)*16
  rectfill(x,55,x+127,71,0) fillp(0x5a5a.8) rectfill(x,56,x+127,70,bn[2]) fillp()
  big(bn[1],x+64,58,7) cpr(bn[4],x+64,73,bn[2])
  if (k>48) bn=nil
 end
 if dlg then
  local s=dlg[1][dlg[2]]
  dlg[3]=min(dlg[3]+1,#s)
  if (dlg[3]%3==0 and dlg[3]<#s) sf(23)
  box(2,74,123,44,12) rectfill(6,78,23,96,1) spr(32,8,80,2,2) print("mago",7,99,12)
  local x,y=28,78
  for w in all(split(sub(s,1,dlg[3])," ",false)) do
   if (x+#w*4>124) x=28 y+=7
   print(w,x,y,7) x+=#w*4+4
  end
  nh={} hs("d",0,0,128,128,function() if dlg[3]<#s then dlg[3]=#s else dlg[2]+=1 dlg[3]=0 sf(1) if (dlg[2]>#dlg[1]) dlg=nil
   end end) foc="d"
 end
 if pas then
  cls() stars() spr(pas==1 and 32 or 34,56,24,2,2)
  cpr("pasa la consola a",64,48,6) big("jugador "..pas,64,58,sc[g.p[pas].s])
  menu({{"estoy listo",function() pas=nil end}},64,74,9)
 end
 if ov then
  ov+=1 local w=g.w local win=mode==2 or w==1
  fillp(0x5a5a.8) rectfill(0,0,127,127,0) fillp() rectfill(0,30,127,98,0)
  if (win and rnd()<.08) burst(20+rnd(88),20+rnd(40),24,{10,14,12,11,7},2,.05) sf(24)
  spr(w==2 and 34 or 32,6,48-(win and abs(sin(t()))*6 or 0),2,2)
  big(win and "victoria" or "derrota",72,36,win and 10 or 6,win and 8 or 1)
  cpr(mode==2 and "gana el jugador "..w or win and "la hechicera cae" or "tu vida llego a 0",72,54,7)
  if ov>30 then menu({{"revancha",function() startg(mode,g.p[1].s,g.p[2].s) end},{"menu",function() go"tit" end}},72,56,10) end
 end
 if (fl>0) fl-=1 fillp(0x5a5a.8) rectfill(0,0,127,127,8) fillp()
end

-- ===== pantallas =====
function stars()
 for i=1,40 do pset(i*37%128,(i*61+t()*(4+i%5))%128,split"1,1,5,13,7"[flr(t()*2+i)%5+1]) end
end
function go(s)
 scr,foc,sb,back,tr=s,nil,nil,nil,16 sf(1)
 if (s=="tit" and opt[1]) music(0,800,7)
end
S={}
function S.tit()
 cls() stars()
 for k=0,5 do dcard(k*9+3,(k*29+t()*9)%150-12,102,sin(t()/5+k/3)>0) end
 sspr(0,64,72,17,28,8+sin(t()/2)*2) sspr(72,64,32,22,48,27+sin(t()/2+.2)*2)
 for s=1,4 do spr(9+s,40+s*9,50+sin(t()+s/4)*1.5) end
 cpr("duelos rapidos",64,58,13)
 menu({{"jugar",function() go"mode" end},{"como jugar",function() pg=1 go"how" end}},64,62,9)
 cpr("reglas oficiales v0.2",64,121,5)
end
function S.mode()
 cls() stars()
 spr(32,6,48+sin(t()/2)*2,2,2) spr(34,106,48-sin(t()/2)*2,2,2,true)
 box(28,30,72,52,7) cpr("selecciona modo",64,35,10)
 local it={}
 for k,s in pairs(split"vs cpu,vs amigo,tutorial") do
  add(it,{s,function() sm,pk=k,{} go"sch" end})
 end
 menu(it,64,34,12)
 back=function() go"tit" end
end
function S.sch()
 cls() stars()
 cpr("elige tu escuela"..(sm==2 and " - j"..(#pk+1) or ""),64,3,10)
 for s=1,4 do
  local y,fo=s*27-15,foc==s
  local x=fo and 5 or 2
  box(x,y,122,24,fo and sc[s] or 5)
  sspr(72+s*8,0,5,5,x+5,y+4,15,15)
  print(sn[s],x+26,y+4,sc[s]) print(pwd[s],x+26,y+11,7) print("1 uso por partida",x+26,y+18,13)
  hs(s,2,y,122,24,function()
   add(pk,s) sf(14) burst(20,y+12,20,{sc[s],7},2)
   if sm!=2 then repeat pk[2]=flr(rnd(4))+1 until pk[2]!=s end
   if (#pk>1) startg(sm,pk[1],pk[2])
  end)
 end
 drawfx()
 back=function() if #pk>0 then deli(pk) else go"mode" end end
end
hw=split("objetivo|cada duelista empieza con 15\nde vida y 7 cartas de una\nbaraja comun de 52.\n\ngana quien baje la vida del\nrival a 0 o menos.#las cartas|a 2 3 4 5 : criaturas\n6 7 8 9 10 : mana\nj q k : hechizos\n\nel palo de cada carta es su\nescuela arcana.\n\nlas cartas usadas vuelven al\nfondo del mazo.#mana|juega 1 carta de mana por\nturno. cada una da 1 mana\nal girarse y se endereza en\ntu siguiente turno.\nel as tambien puede dar mana.\nel pago es automatico.#criaturas|coste - ataque/defensa\na: 1 - 1/1    2: 2 - 2/2\n3: 2 - 3/3    4: 3 - 4/4\n5: 3 - 5/5\n\nno atacan el turno en que\nentran (zz) pero si bloquean.\nmaximo 5 en juego.#hechizos|j: cancela un atacante (1)\n   o imbloqueable (1)\nq: +0/+2 (1) o +4 vida (3)\nk: +1/+0 (1) o 1 dano (1)\n\nlos bonus duran hasta el fin\ndel turno.#combate|elige atacantes: se giran.\nel rival asigna bloqueos,\nuno por atacante. las cartas\ngiradas no pueden bloquear.\nluego ambos pueden lanzar\nhechizos, empezando por\nquien ataca.\nsin bloqueo: dano al jugador.\ncon bloqueo: dano mutuo.#escuelas|al jugar una carta de tu palo\npuedes activar tu poder una\nvez por partida sobre una\ncriatura:\n\n  vitalis: tuya +1 defensa\n  aether: rival -1 defensa\n  grove: tuya +1 ataque\n  ruin: rival 1 dano\n\nataque y defensa cambian para\nsiempre. el dano se cura al\nfinal del turno.#controles|flechas: elegir\n🅾️ (z): aceptar\n❎ (x): volver / reservar\nenter: menu de pausa\n(musica y ayudas)","#",false)
function S.how()
 cls(1) local p=split(hw[pg],"|",false)
 cpr("como jugar "..pg.."/"..#hw,64,3,13)
 big(p[1],64,13,9)
 print(p[2],6,30,7)
 if pg==7 then for s=1,4 do spr(9+s,6,54+s*6) end end
 cpr("⬅️➡️ pagina  ❎ volver",64,120,13)
 back=function() go"tit" end
end

-- ===== bucle =====
mo=split"musica,ayudas"
function mi(n)
 menuitem(n,mo[n]..": "..(opt[n] and "si" or "no"),function()
  opt[n]=not opt[n] mi(n)
  if (n==1) music(opt[1] and (scr=="game" and 2 or 0) or -1,0,7)
  return true
 end)
end
function _init()
 opt={true,true}
 mi(1) mi(2)
 mt,tr,sh,fl,pt=0,0,0,0,{}
 go"tit"
end
function _update60()
 hot,bk=nh,t()*4%2<1
 if (not hget(foc) and hot[1]) foc=hot[1].id
 if tr<8 then
  if scr=="how" then
   if (btnp(0)) pg=max(pg-1,1) sf(4)
   if (btnp(1)) pg=min(pg+1,#hw) sf(4)
  else
   for b=0,3 do if (btnp(b)) nav(b)
   end
  end
  if (btnp(4) and hget(foc)) hget(foc).f()
  if btnp(5) then if scr=="game" then gback() elseif back then sf(2) back() end end
 end
 if (scr=="game" and costatus(dir)!="dead") assert(coresume(dir))
end
function _draw()
 nh={}
 camera(rnd(sh)-sh/2,rnd(sh)-sh/2) sh*=.8
 if scr=="game" then drgame() else S[scr]() end
 camera()
 if tr>0 then
  tr-=1 local k=min(tr,16-tr)
  if k>0 then for y=0,127,8 do rectfill(0,y,127,y+k-1,0) end end
 end
end

__gfx__
000000000088880000666600800000080008800020000002000c00000007000009999990000000708808800000c0000000b0000000d000000777770000000000
000000000888888006777760088888800066660008000080000c0000000e000009aaaa9000000760888880000ccc00000bbb00000ddd00007777777000000000
00000000087887800707707008a88a80060000600888888000ccc0000e0e0e00098aa8900000760088888000ccccc000b0b0b000ddddd0007007007000000000
0000000008088080006776000888888000666600087887800cc7cc0000eee0000988889000076000088800000ccc0000bbbbb000ddddd0007777777000000000
0000000008888880080660800080080008888880288888820c7cccc07eeeee7009a88a90907600000080000000c0000000b000000d0d00000770770000000000
0000000008888880088668800222222068288286208aa8020cccccc000eee000009aa90009760000000000000000000000000000000000000707070000000000
0000000008282820006006000822228008888880008888000cccc1c00e0e0e000009900000990000000000000000000000000000000000000000000000000000
00000000080808000660066000800800066006600880088000c11c00000700000000000004009000000000000000000000000000000000000000000000000000
00000000000000000000000000000000aaa00000aaaaa000a0000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000000000000000000000000000000a000000aaa0000aa000000000000000000000000000000000000000000000000000000000000000000000000000000
000000000000000000000000000000000a00aa0000a00000aaa00000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000aaa00a0000000000aa000000000000000000000000000000000000000000000000000000000000000000000000000000
000000000000000000000000000000000000a00000000000a0000000000000000000000000000000000000000000000000000000000000000000000000000000
000000000000000000000000000000000000aa000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000cc00000000000000880000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
000000cccc0000000000008880000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000ccacc0009000000088a88000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000cccccc00a9a00000888888000e00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
000cccccccc00900000888888880eee0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
01111111111004000222222222200e00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
000ffffff00004000099ffffff900400000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
000f0ff0f0000400009f0ff0f9900400000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
000ffffff000f400009ffeeff900f400000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00777777770cc4000099ffff99088000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0cc777777ccc04000888888888880400000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0cc077770c0004000808888880800400000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0001cccc100004000002888882000400000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
000cccccc00004000008888888800400000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00cccccccc0004000088888888880400000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00110000110004000022000000220400000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00022222000022222222000000022222222000022222000022222222000022222222222022222222222222002222222222000000000000000000000000000000
0002aaa200002aaaaaa200000002aaaaaa200002aaa200002aaaaaa200002aaaaaaaaa202cccccccccccc2002cccccccc2000000000000000000000000000000
0002aaa200002aaaaaa200000002aaaaaa200002aaa200002aaaaaa200002aaaaaaaaa202cccccccccccc2002cccccccc2000000000000000000000000000000
2222aaa222202aaaaaa222202222aaaaaa202222aaa222202aaaaaa222202aaaaaaaaa202cccccccccccc2002cccccccc2000000000000000000000000000000
2aaa222aaa202aaa222aaa202aaa222222202aaa222aaa202aaa222aaa202aaa222222202cccccccccccc2002cccccccc2222200000000000000000000000000
2aaa202aaa202aaa202aaa202aaa200000002aaa202aaa202aaa202aaa202aaa200000002cccc22222222200222222222cccc200000000000000000000000000
2aaa222aaa202aaa222aaa202aaa200000002aaa222aaa202aaa202aaa202aaa222200002cccc20000000000000000002cccc200000000000000000000000000
2999999999202999999222202999200000002999999999202999202999202999999200002cccc20000000000000000002cccc200000000000000000000000000
2999999999202999999200002999200000002999999999202999202999202999999200002cccc22222000000000022222cccc200000000000000000000000000
2999999999202999999222202999200000002999999999202999202999202999999200002cccccccc200000000002cccc2222200000000000000000000000000
2999222999202999222999202999200000002999222999202999202999202999222200002cccccccc200000000002cccc2000000000000000000000000000000
2999202999202999202999202999200000002999202999202999202999202999200000002cccccccc200000000002cccc2000000000000000000000000000000
2999202999202999202999202999222222202999202999202999202999202999222222202cccccccc222220022222cccc2000000000000000000000000000000
288820288820288820288820222288888820288820288820288820288820288888888820222222222cccc2002cccc22222000000000000000000000000000000
288820288820288820288820000288888820288820288820288820288820288888888820000000002cccc2002cccc20000000000000000000000000000000000
288820288820288820288820000288888820288820288820288820288820288888888820000000002cccc2002cccc20000000000000000000000000000000000
22222022222022222022222000022222222022222022222022222022222022222222222022222222211112002111122222222200000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000021111111122222002111111111111200000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000021111111120000002111111111111200000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000021111111120000002111111111111200000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000021111111120000002111111111111200000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000022222222220000002222222222222200000000000000000000000000
__sfx__
010301003443500000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
01040200284402f445000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
01040200234301c435000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
010503000125000000012550000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
010204001e630266302e6203442500000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
01030500284402c4402f440344403b445000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
01030800183401c3401f340243402b340000730006300045000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
01020a003043234432374323c43237432344323043234432374323c43500000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
010206003c64036650306402a630246201e6100000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
01030300186730c353126450000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
01040500090730e670040630a64500035000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
010407001f3501b35018350133500c350146550c63500000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0104060024050280502b0503005034050370550000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
010304002d44031440344403944500000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
01030b00184501f45024450284502b450304503445037452374420007300055000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
010604002b450304502b4203042500000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
010203003866030343326350000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0102070028640000002c6400000028630000002e63500000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
010206003a440344402e44028440224401c4350000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
01100a0024350283502b35030350000002b3503036030360303523034500000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
01180900210501f0501d0501c0501a0500000019052190421a0450000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
010201002842500000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
010302002c6531e635000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
011e00002805028052280522805524050240552105021055230502305223052230551f0501f0551c0501c05521050210522105524050290502905528050280552005020052200522005523050230552805028055
011e00000904009040090400904515030150301503015035040400404004040040451003010030100301003505040050400504005045110301103011030110350404004040040400404510030100301003010035
011e000021425184251c4252d42521425184251c4252d4251c4251f42523425284251c4251f42523425284251d4252142518425294251d4252142518425294251c4252042523425284251c425204252342528425
011e00002d0502d0522d0552b05028050280552405024055290502905229055280502605026055210502105524050240552105021055290502905528050280552805028052280522805523050230552005020055
011e00000904009040090400904515030150301503015035020400204002040020450e0300e0300e0300e03505040050400504005045110301103011030110350404004040040400404510030100301003010035
011e000021425184251c4252d42521425184251c4252d4251a4251d42521425264251a4251d42521425264251d4252142518425294251d4252142518425294251c4252042523425284251c425204252342528425
010d000021330213352433024335283302833228332283352633026335243302433523330233352433024335213302133221332213351d3301d33521330213352433024332243322433521330213322133221335
010d00000905009055090500905515050150550905009055090500905509050090551505015055040500405505050050550505005055110501105505050050550505005055050500505511050110550005000055
010d00000c073244153a6252441520655244153a625244150c073244150c0732441520655244153a625206550c0732d4153a6252d415206552d4153a6252d4150c0732d4150c0732d415206552d4153a62520655
010d00001f3301f3352433024335283302833228332283352b3302b3322b3322b3352833028335263302633526330263322633226332263322633523330233351f3301f3321f3321f33523330233322333223335
010d0000000500005500050000550c0500c0550005000055000500005500050000550c0500c055070500705507050070550705007055130501305507050070550705007055070500705513050130550205002055
010d00000c073284153a6252841520655284153a625284150c073284150c0732841520655284153a625206550c0732f4153a6252f415206552f4153a6252f4150c0732f4150c0732f415206552f4153a62520655
010d0000283302833528330283352d3302d3322d3322d3352b3302b33528330283352633026335283302833524330243322433224335213302133524330243352933029332293322933528330283352633026335
010d00000905009055090500905515050150550905009055090500905509050090551505015055040500405505050050550505005055110501105505050050550505005055050500505511050110550005000055
010d00000c073244153a6252441520655244153a625244150c073244150c0732441520655244153a625206550c0732d4153a6252d415206552d4153a6252d4150c0732d4150c0732d415206552d4153a62520655
010d0000263302633523330233351f3301f3352333023335263302633226332263352b3302b3322b3322b3352c3302c3322c3322c335283302833228332283352333023332233322333520330203322033220335
010d00000705007055070500705513050130550705007055070500705507050070551305013055020500205504050040550405004055100501005504050040550405004055040500405510050100550b0500b055
010d00000c0732f4153a6252f415206552f4153a6252f4150c0732f4150c0732f415206552f4153a625206550c0732c4153a6252c415206552c4153a6252c4150c0732c4150c0732c415206552c4153a62520655
__music__
01 20212244
02 23242544
01 26272844
00 292a2b44
00 2c2d2e44
02 2f303144
__label__
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000002222200002222222200000002222222200002222200002222222200002222222222200000000000000000000000000000
00000000000000000000d00000000002aaa200002aaaaaa200000002aaaaaa200002aaa200002aaaaaa200002aaaaaaaaa200000000000000000000000000000
00000000000000000000000000000002aaa200002aaaaaa200000002aaaaaa200002aaa200102aaaaaa200002aaaaaaaaa200000000000000000000000000000
00000000000000000000000000002222aaa222202aaaaaa222202222aaaaaa202222aaa222202aaaaaa222202aaaaaaaaa200000000000000000000000000000
00000000000000000000000000002aaa222aaa202aaa222aaa202aaa222222202aaa222aaa202aaa222aaa202aaa222222200000000000000000000000000000
00000000000000000000000000002aaa202aaa202aaa202aaa202aaa200000002aaa202aaa202aaa202aaa202aaa200000000000000000000000000000000000
00000000000000000000000000002aaa222aaa202aaa222aaa202aaa200000002aaa222aaa202aaa202aaa202aaa222200000000000000000000000000000000
00000000010000000000000000002999999999202999999222202999200000002999999999202999202999202999999200000000000000000000000000000000
00000000000000000000000000002999999999202999999200002999200000002999999999202999202999202999999200000000000000000000000000000000
00000000000000000000000000002999999999202999999222202999200000002999999999202999202999202999999200000000000000000000000000000000
00000000000000000000000000002999222999202999222999202999200000002999222999202999202999202999222200000000000000000000000000000000
00000000000000000000000000002999202999202999202999202999200000002999202999202999202999202999200000000000000000000000000000000000
00000000000000000000000000002999202999202999202999202999222222202999202999202999202999202999222222200000000000000000000000000000
00000000000000000000000000002888202888202888202888202222888888202888202888202888202888202888888888200000000000000000000000000000
00000000000000000000000000002888202888202888202888200002888888202888202888202888202888202888888888200000000000000000000000000000
00000000000000000000000000002888202888202888202888200002888888202888202888202888202888202888888888200000000000000000000000000000
00000000000000000000000000002222202222202222202222200002222222202222202222202222202222202222222222200000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
000000000000000000000000000000000000000000000000222222222222220d2222222222000000000000000000000000000000000000000000000000000000
0000000000000000000000000000000000000000000000002cccccccccccc2002cccccccc2000000000000000000000000000000000000000000010000000000
0000000000000000000000000000000000000000000700002cccccccccccc2002cccccccc2000000000000000000000000000000000000000000000000000000
0000000000000000000000000000000000000000000000002cccccccccccc2002cccccccc2000000000000000000000000000000000000000000000000000000
0000000000000000000000000000000000000000000000002cccccccccccc2002cccccccc2222200000000000000000000000000000000000000000000000000
0000000000000000000000000000000000000000000000002cccc22222222200222222222cccc200000000000000000000000000000000000000000000000050
0000000000000000000000000000000000000000000000002cccc20000000000000000002cccc200000000000000000000000000000000000000000000000000
0000000000000000000000000000000000000000000000002cccc20000000000000000002cccc200000000000000000000000000000000000000000000000000
0000000000000000000000000000000000000000000000002cccc22222000000000022222cccc200000000000000000000000000000000000000000000000000
0000000000000000000000000000000000000000000000002cccccccc200000000002cccc2222200000000000000000000000000000000000000000000000000
0000000000000000000000000000000000000000000000002cccccccc200000000002cccc2000000000000000000000000000000000000000000000000000000
0000000000000000000000000000000000000000000000002cccccccc200000000002cccc2000000000000000000000000000000000000000000000000000000
0000000000000000000000000000000000000000000000002cccccccc222220022222cccc2000000000000000000000000000000000000000000000000000000
000000000000000000000000000000000000000000000000222222222cccc2002cccc22222000000000000000000000000000000000000000000000000000000
000000000000000000000000000000000000000000000000000000002cccc2002cccc20000000000000000000000000000000000000000000000000000000000
000000000000000000000000000000000000000000000000000000002cccc2002cccc20000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000022222222211112002111122222222200000000000000000005000000000000000000000000000000
00000000000000000000000100000000000000000000000021111111122222002111111111111200000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000021111111120000002111111111111200000000000000000000000000000000000000000000000000
0000000000000000000000000000000000000000000000002111111112000000211111111111120000000000000000000000000000d000000000000000000000
00000000000000000000000000000000100000000000000021111111120000002111111111111200000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000022222222220000002222222222222200000000700000000000000000000000000000000000000000
000000000000000000000000000000000000000000000000000000000000000000000b0000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000bbb0000000d0000000000000000000000000000000000000000000000000
000000000000000000000000000000000000000000000000000000000000c000000b0b0b00000ddd000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000008808800000ccc00000bbbbb0000ddddd00000000000000000000000000000000000000000000000
0000000000000000000000000000000000000000000000000888880000ccccc000000b000000ddddd00000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000008888800000ccc000000000000000d0d000000000000000000000000000000000000000000000000
000000000000000000000000000000000000000000000000008880000000c0000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000080000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000d00000000000000000000000000000000000000000000000000
00010000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
000000000000000000000000000000000000dd00d0d0ddd0d0000dd00dd00000ddd0ddd0ddd0ddd0dd000dd00dd0000000000000000000000000000000000000
000000000000000000000000000000000000d0d0d0d0d000d000d0d0d0000000d0d0d0d0d0d00d00d0d0d0d0d000000000000000000000000000000000000000
000000000000000000000000000000000000d0d0d0d0dd00d000d0d0ddd00000dd00ddd0ddd00d00d0d0d0d0ddd0000000000000000000000000000000000000
000000000000500000000000000000000000d0d0d0d0d000d000d0d000d00000d0d0d0d0d0000d00d0d0d0d000d0000000000000000000000000000000000000
000000000000000000000000000000000000ddd00dd0ddd0ddd0dd00dd000000d0d0d0d0d000ddd0ddd0dd00dd00000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000a000000aaa0a0a00aa0aaa0aaa0000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000aa000000a00a0a0a000a0a0a0a0000000000000000000000000000000000000050000000000000000
00000000000000000000000000000000000001000000000aaa00000a00a0a0a000aaa0aa00000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000aa000000a00a0a0a0a0a0a0a0a0000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000a000000aa000aa0aaa0a0a0a0a00000000000000000000000000000000000000000000000d0000000
00000000000000000000000000000000000000000000001000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000007000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000077007707770077000007770707007707770777000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000700070707770707000000700707070007070707000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000700070707070707000000700707070007770770000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000700070707070707000000700707070707070707000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000077077007070770000007700077077707070707000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000500000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000100000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000d00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000100000000000000000000000000000000000000
00000000000000070000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000ffffffffffffffffff0000000000000000eeeeeeeeeeeee0000000000000000fffffffffffff0000000000000000fffffffffffff0000000000000000ee
00000f21212121212f2121f0000000000000000e22222222222e0000000000000000f12121212121f0000000000000000f21212121212f0000000000000000e2
00000f12121212121f1212f0000000000000000e22722288288e0000000000000000f21212121212f0000000000000000f12121212121f0000000000000000e2
00000f21999999912f9921f0000000000000000e27272288888e0000000000000000f12999999921f0000000000000000f21999999912f0000000000000000e2
00000f12921212921f1912f0000000000000000e27272288888e0000000010000000f21912121912f0000000000000000f12921212921f0000000000000000e2
00000f21912121912f2921f0000000000000000e27722228882e0000000000000000f12921212921f0000000000000000f21912121912f0000700000000000e2
00000f12921212921f1912f0000000000000000e22772222822e0000000000000000f21912121912f0000000000000000f12921212921f0000000000000000e2
00000f21912121912f2921f0000000000000000e22222222222e0000000000000000f12921212921f0000000000000000f21912121912f0000000000000000e2
00000f12921212921f1912f0000000000000000e22299999922e0000000000000000f21912121912f0000000000000000f12921212921f0000000000000000e2
00000f21912121912f2921f0000000000000000e2229aaaa922e0000000000000000f12921212921f0000000000000000f21912121912f0000000000000100e2
00000f12921212921f1912f0000000000000000e22298aa8922e0000000000000000f21912121912f0000000000000000f12921212921f0000000000000000e2
00000f21912121912f2921f0000000000000000e22298888922e0000000000000000f12921212921f0000000000000000f21912121912f0000000000000000e2
00000f12921212921f1912f0000000000000000e2229a88a922e0000000000000000f21912121912f0000000000000000f12921212921f0000000000000000e2
00000f21999999912f9921f0000000000000000e22229aa9222e0000000000000000f12999999921f0000000000000000f21999999912f0000000000000000e2
00000f12121212121f1212f0000000000000000e22222992222e0000000000000000f21212121212f0000000000000000f12121212121f0000000000000000e2
00000f21212121212f2121f0000000000000000e22222222222e0000000000000000f12121212121f0000000000000000f21212121212f0000000000000000e2
00000ffffffffffffffffff0000000000000000eeeeeeeeeeeee0000000000000000fffffffffffff0000000000000000fffffffffffff0000000000000000ee
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000005550555005505000555005500000055055505550055055505550500055500550000050505550000055500000000000000000000000
00000000000000000000005050500050005000505050000000505050000500500005005050500050005000000050505050000000500000000000000000000000
00000000000000000000005500550050005000555055500000505055000500500005005550500055005550000050505050000055500000000000000000000000
0000000000000000000000505050005050500050500050000d505050000500500005005050500050000050000055505050000050000000000000000000000000
00000000000000000000005050555055505550505055000000550050005550055055505050555055505500000005005550050055500000000000000000000000
00000000000000000000000000000700000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
