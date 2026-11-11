from pathlib import Path
import hashlib,json,os,resource,sys
root=Path('/tmp/reussir-paper-refresh-20261111')
sys.path.insert(0,str(root/'benchmark'))
from config import CONFIG
import runner
CONFIG.update({'runs':3,'warmup-runs':2,'case-time-budget-seconds':60})
resource.setrlimit(resource.RLIMIT_STACK,(resource.RLIM_INFINITY,resource.RLIM_INFINITY))
os.sched_setaffinity(0,{19})
env=runner._runtime_env('lean');env['LEAN_BACKTRACE']='0'
variants={'before980':Path('/home/schrodingerzy/Documents/paper-evidence-20261110/lean434/cells/life/l2r'),'pr980':root/'lean2rr/cells/life/l2r','fixed':root/'lean2rr-fixed/cells/life/l2r'}
expected={x['benchmark']:x['binary_sha256'] for x in json.loads((root/'lean2rr-fixed/baseline-measurements.json').read_text()) if x['variant']=='l2r'}
assert hashlib.sha256(variants['before980'].read_bytes()).hexdigest()==expected['life']
rows=[]
for name,binary in variants.items():
 m=runner.measure_executable(str(binary),env)
 assert m['results'][0]['exit_codes']==[0]*3
 rows.append({'variant':name,'binary_sha256':hashlib.sha256(binary.read_bytes()).hexdigest(),'measurement':m})
 (root/'diagnostic/lean-life-results.json').write_text(json.dumps(rows,indent=2)+'\n')
 print(name,m['results'][0]['mean'],m['peak_rss_kb'],flush=True)
