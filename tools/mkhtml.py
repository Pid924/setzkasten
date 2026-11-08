import json,os
S=os.path.dirname(os.path.abspath(__file__))
t=json.load(open(S+'/trans.json',encoding='utf-8'))
for k,v in t.items():
    v[2]=', '.join(v[2].split(', ')[:2]) if v[2] else ''
    if ' / ' not in v[1]: v[1]=', '.join(v[1].split(', ')[:2]) if v[1] else ''
words=open(S+'/words_final.txt').read()
data='const WORDS="'+words+'";\nconst GLOSS='+json.dumps(t,ensure_ascii=False,separators=(',',':'))+';\n'
html=open(S+'/template.html',encoding='utf-8').read().replace('/*DATA*/',data)
open(S+'/setzkasten.html','w',encoding='utf-8').write(html); print(len(html.encode()))
