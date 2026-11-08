import csv,re,json,sys,os,xml.etree.ElementTree as ET
from collections import defaultdict
S=os.path.dirname(os.path.abspath(__file__))
os.environ['NLTK_DATA']=S+'/nltk_data'
from nltk.corpus import wordnet as wn
norm=lambda s:s.lower().replace('ß','ss')
words=open(S+'/words.txt',encoding='utf-8').read().split()
# curated thai gloss
cur={}
for l in open(S+'/gloss.txt',encoding='utf-8'):
    l=l.strip()
    if not l: continue
    disp,th=l.split('|'); key=norm(disp.split()[-1])
    cur.setdefault(key,[]).append((disp,th))
for k in cur: words.append(k)
words=sorted(set(w for w in words if 3<=len(w)<=12))
# nouns
csv.field_size_limit(10**8)
G={'m':'der','f':'die','n':'das'}
noun_lemma={}; noun_gen={}; PROPER=set()
with open(S+'/pyp/gn/german_nouns/nouns.csv',encoding='utf-8') as f:
    r=csv.reader(f); hdr=next(r)
    formcols=[i for i,h in enumerate(hdr) if re.match('(nominativ|genitiv|dativ|akkusativ) (singular|plural)',h)]
    gcols=[i for i,h in enumerate(hdr) if h.startswith('genus')]
    for row in r:
        lem=row[0]
        if not lem or ' ' in lem: continue
        isprop=any(x in row[1] for x in ('Eigenname','Nachname','Vorname','Toponym','Straßenname','Abkürzung'))
        if isprop:
            for i in [0]+formcols:
                if i<len(row) and row[i]: PROPER.add(norm(row[i]))
            PROPER.add(norm(lem)+'s')
            continue
        g=next((row[i] for i in gcols if row[i] in G),None)
        if g and lem not in noun_gen: noun_gen[lem]=G[g]
        for i in [0]+formcols:
            if i<len(row) and row[i]:
                k=norm(row[i])
                if k==norm(lem): noun_lemma[k]=lem
                else: noun_lemma.setdefault(k,lem)
# ili->pwn
ili={}
for l in open(S+'/wn/ili-map-pwn30.tab'):
    a,b=l.split(); ili[a]=b
def omw(path):
    d=defaultdict(list)
    for l in open(path,encoding='utf-8'):
        if l.startswith('#'): continue
        p=l.rstrip('\n').split('\t')
        if len(p)>=3 and p[1].endswith('lemma'):
            k=p[0].replace('-s','-a'); 
            if p[2] not in d[k]: d[k].append(p[2])
    return d
THA=omw(S+'/wn/wn-data-tha.tab'); NLD=omw(S+'/wn/wn-data-nld.tab')
# odenet
syn_ili={}; lem_syn=defaultdict(list)
for ev,el in ET.iterparse(S+'/wn/deWordNet.xml'):
    if el.tag=='Synset': syn_ili[el.get('id')]=el.get('ili'); el.clear()
    elif el.tag=='LexicalEntry':
        lm=el.find('Lemma').get('writtenForm')
        for s in el.findall('Sense'): lem_syn[lm].append(s.get('synset'))
        el.clear()
def pwn(sid):
    i=syn_ili.get(sid); o=ili.get(i) if i else None
    if not o: return None,None
    off,pos=o.split('-'); key=off+'-'+('a' if pos=='s' else pos)
    try: ss=wn.synset_from_pos_and_offset(pos,int(off))
    except Exception: ss=None
    return key,ss
def wn_trans(lemma):
    sids=lem_syn.get(lemma)
    if not sids: return None
    cand=[]
    for sid in sids:
        key,ss=pwn(sid)
        if not key: continue
        cnt=sum(l.count() for l in ss.lemmas()) if ss else 0
        cand.append((cnt,key,ss))
    if not cand: return None
    cand.sort(key=lambda x:-x[0])
    en=[];th=[];nl=[]
    for cnt,key,ss in cand[:3]:
        if ss:
            for l in ss.lemmas()[:2]:
                n=l.name().replace('_',' ')
                if n.lower()!=lemma.lower() or not en:
                    if n not in en: en.append(n)
        for t in THA.get(key,[])[:2]:
            if t not in th: th.append(t)
        for t in NLD.get(key,[])[:2]:
            if t not in nl: nl.append(t)
    return en[:4],th[:3],nl[:3]

def tei(path):
    D=defaultdict(list); root=ET.parse(path).getroot(); ns='{http://www.tei-c.org/ns/1.0}'
    for e in root.iter(ns+'entry'):
        o=e.find('.//'+ns+'orth')
        if o is None or not o.text: continue
        for q in e.iter(ns+'quote'):
            t=(q.text or '').strip().replace('ĳ','ij').replace('Ĳ','IJ')
            if t and t not in D[o.text]: D[o.text].append(t)
    return D
FD=tei(S+'/wn/deu-nld.tei'); NE=tei(S+'/wn/nld-eng.tei')
NE_l={k.lower():v for k,v in NE.items()}
EN=json.load(open(S+'/en_extra.json',encoding='utf-8')) if os.path.exists(S+'/en_extra.json') else {}
from spylls.hunspell import Dictionary
hd=Dictionary.from_files(S+'/dict/de')
def stems(w):
    out=[]
    for c in [w,w.capitalize()]:
        try:
            for f in hd.lookuper.good_forms(c):
                if f.stem not in out: out.append(f.stem)
        except Exception: pass
    return out
def cands(w):
    c=[w,w.capitalize()]+stems(w)
    if w in noun_lemma: c.append(noun_lemma[w])
    if 'ss' in w: c+= [x.replace('ss','ß') for x in c]
    seen=[];[seen.append(x) for x in c if x not in seen]; return seen
def de_keys(lemma):
    ks=set()
    for sid in lem_syn.get(lemma,[]):
        k,_=pwn(sid)
        if k: ks.add(k)
    return ks
def sskey(ss): return '%08d-%s'%(ss.offset(),'a' if ss.pos()=='s' else ss.pos())
FX=json.load(open(S+'/fx.json',encoding='utf-8'))
def encount(e):
    n=e.replace(' ','_').lower(); c=0
    for ss in wn.synsets(n):
        for l in ss.lemmas():
            if l.name().lower()==n: c+=l.count()
    return c
def pivot(lemma):
    nl=[]; key=lemma
    for v in (lemma,lemma.capitalize(),lemma.lower(),lemma.replace('ss','ß'),lemma.capitalize().replace('ss','ß')):
        if FD.get(v): nl=FD[v][:3]; key=v; break
    lemma=key
    en=[]
    for n in nl:
        for e in NE.get(n) or NE_l.get(n.lower(),[]):
            if e not in en: en.append(e)
    if not en: return nl,en,key
    dk=de_keys(lemma)
    def score(e):
        hit=any(sskey(ss) in dk for ss in wn.synsets(e.replace(' ','_'))[:8])
        return (hit, encount(e)+ (1 if e in (NE.get(nl[0]) or []) else 0))
    en.sort(key=score,reverse=True)
    hits=[e for e in en if score(e)[0]]
    if hits: return nl,hits[:3],key
    if dk:
        t=wn_trans(lemma)
        if t and t[0]: return nl,t[0][:3],key
    best=[e for e in en if score(e)!=(False,0)] or en
    return nl,best[:3],key
def thai_for(lemma,en):
    dk=de_keys(lemma)
    for e in en:
        for ss in wn.synsets(e.replace(' ','_'))[:6]:
            k=sskey(ss)
            if k in dk and THA.get(k): return ', '.join(THA[k][:3])
    if en:
        ss=wn.synsets(en[0].replace(' ','_'))
        if ss and THA.get(sskey(ss[0])): return ', '.join(THA[sskey(ss[0])][:3])
    return ''
def disp_of(lem):
    g=noun_gen.get(lem) if lem[:1].isupper() else None
    return (g+' '+lem) if g else lem
common=set(noun_lemma)
removed=[w for w in words if w in PROPER and w not in common and w not in cur and w not in FX and not hd.lookup(w)]
print('removed proper',len(removed),removed[:40])
words=[w for w in words if w not in set(removed)]
out={}; stats=defaultdict(int)
for w in words:
    entry=None
    cl=cands(w)
    # pass 1: curated / freedict-backed lemma
    for lem in cl:
        nl,en,k2=pivot(lem)
        if nl: lem=k2
        e2=None
        if norm(lem)==w and w in FX:
            e2=FX[w][0]; en=[e2]; nl=[FX[w][1]]
        if not (nl or e2 or (w in cur and lem in (w,w.capitalize()))): continue
        th=''
        if w in cur and norm(lem)==w: th=' / '.join(t for _,t in cur[w])
        elif norm(lem) in cur: th=' / '.join(t for _,t in cur[norm(lem)])
        if not th and w not in FX: th=thai_for(lem,en)
        d=' / '.join(x for x,_ in cur[norm(lem)]) if norm(lem) in cur else disp_of(lem)
        entry=[d,th,', '.join(en[:3]),', '.join(nl)]; break
    # pass 2: wordnet only (exact or stem lemma)
    if not entry:
        for lem in cl:
            t=wn_trans(lem)
            if t and (t[0] or t[2]):
                entry=[disp_of(lem),'',', '.join(t[0][:2]),', '.join(t[2][:2])]; break
    if entry and (entry[1] or entry[2] or entry[3]):
        out[w]=entry; stats['any']+=1
        for i,k in [(1,'th'),(2,'en'),(3,'nl')]: stats[k]+=bool(entry[i])
print(len(words),dict(stats))
json.dump(out,open(S+'/trans.json','w',encoding='utf-8'),ensure_ascii=False)
open(S+'/words_final.txt','w').write(' '.join(words))
