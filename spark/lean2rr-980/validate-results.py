import hashlib,json,sys
from pathlib import Path
root=Path(sys.argv[1]).resolve()
expected=['rbtree-zipper-lambda','rbtree','heap','nbe-closure','nbe-hoas','functional-queue','hash-map-linear','heap-functional','qsort','ordered-map-linear','rbtree-zipper','ordered-map-shared','life','ordered-map-heavily-shared','fingertree','hash-map-shared','derive','hash-map-heavily-shared']
assert (root/'membership.txt').read_text().splitlines()==expected
rows=[]
for name in expected:
 p=root/'cells'/name
 assert 'l2r: rrc crashed' not in (p/'build-l2r.log').read_text(),name
 for suffix in ['out','err','code']:
  assert (p/('native.'+suffix)).read_bytes()==(p/('l2r.'+suffix)).read_bytes(),(name,suffix)
 assert (p/'native.code').read_text().strip()=='0',name
 rows.append({'name':name,'native_sha256':hashlib.sha256((p/'native').read_bytes()).hexdigest(),'extracted_sha256':hashlib.sha256((p/'l2r').read_bytes()).hexdigest(),'source_sha256':hashlib.sha256((p/(name+'.lean')).read_bytes()).hexdigest(),'exit_code':0,'stdout_equal':True,'stderr_equal':True,'fallback':False})
(root/'correctness-results.json').write_text(json.dumps(rows,indent=2)+'\n')
print('All18 pairs passed with exit0 and no compiler fallback.')
