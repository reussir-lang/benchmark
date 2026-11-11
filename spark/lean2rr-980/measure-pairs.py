# Run only on released Spark, in benchmark pinned Nix shell, under taskset -c19.
import datetime,hashlib,json,os,platform,resource,sys
from pathlib import Path
root=Path(os.environ['EVIDENCE_OUT']).resolve()
bench=Path(os.environ['BENCHMARK_CHECKOUT']).resolve()
assert platform.machine()=='aarch64'
assert os.sched_getaffinity(0)=={19}
assert not (root/'measurements.json').exists()
verified=json.loads((root/'correctness-results.json').read_text());assert len(verified)==18
sys.path.insert(0,str(bench));import runner
from config import CONFIG
CONFIG.update({'runs':10,'warmup-runs':5,'case-time-budget-seconds':300})
resource.setrlimit(resource.RLIMIT_STACK,(resource.RLIM_INFINITY,resource.RLIM_INFINITY))
env=runner._runtime_env('lean');env['LEAN_BACKTRACE']='0'
(root/'measurement-start.json').write_text(json.dumps({'date':datetime.datetime.now(datetime.timezone.utc).isoformat(),'affinity':list(os.sched_getaffinity(0)),'loadavg':os.getloadavg(),'uname':list(os.uname()),'config':CONFIG},indent=2,default=str)+'\n')
results=[]
for row in verified:
 for variant,key in [('l2r','extracted_sha256')]:
  exe=root/'cells'/row['name']/variant
  digest=hashlib.sha256(exe.read_bytes()).hexdigest();assert digest==row[key]
  result={'benchmark':row['name'],'variant':variant,'binary_sha256':digest,'started':datetime.datetime.now(datetime.timezone.utc).isoformat()}
  try:result['measurement']=runner.measure_executable(str(exe),env)
  except Exception as e:
   result['error']=repr(e);results.append(result);(root/'measurements.json').write_text(json.dumps(results,indent=2)+'\n');raise
  results.append(result);(root/'measurements.json').write_text(json.dumps(results,indent=2)+'\n')
  print('MEASURED',row['name'],variant,flush=True)
(root/'measurement-end.txt').write_text(datetime.datetime.now(datetime.timezone.utc).isoformat()+'\n')
