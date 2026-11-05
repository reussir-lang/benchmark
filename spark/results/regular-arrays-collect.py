from pathlib import Path
import hashlib,json,os,resource,subprocess,sys,time

ROOT=Path(__file__).resolve().parent
BENCH=Path(sys.argv[1]).resolve()
HOST=sys.argv[2]
MODE=sys.argv[3]
sys.path.insert(0,str(BENCH))
from config import CONFIG
from benches import BENCHES,VARIANTS
import compile as compiler
import runner
CASES=('rgba-composite','pcm-mix-limit')

def write(name,value):
    (ROOT/name).write_text(json.dumps(value,indent=2)+'\n')
def read(name,default=None):
    p=ROOT/name
    return json.loads(p.read_text()) if p.exists() else default
def published(name):
    return json.loads(subprocess.check_output(['git','show',f'origin/data:{HOST}/results/{name}.json'],cwd=BENCH))

native=published('native-toolchains-manifest')
primary=published('reussir-manifest')
CONFIG.update(native['config'])
CONFIG.update({k:v for k,v in primary['config'].items() if k.startswith('reussir-')})
CONFIG.update({'runs':10,'warmup-runs':5,'compile-timeout-seconds':60,'case-time-budget-seconds':300})
if native.get('ocamlpath'):os.environ['OCAMLPATH']=native['ocamlpath']
for name in ('NIX_ENFORCE_NO_NATIVE','NIX_ENFORCE_NO_NATIVE_x86_64_unknown_linux_gnu','NIX_ENFORCE_NO_NATIVE_aarch64_unknown_linux_gnu'):
    os.environ[name]='0'
resource.setrlimit(resource.RLIMIT_STACK,(resource.RLIM_INFINITY,resource.RLIM_INFINITY))
targets=[(b,v) for b in CASES for v in BENCHES[b]['sources']]
assert len(targets)==18 and all(v!='reussir-nrac' for b,v in targets)
commands=read('commands.json',[])
real_run=compiler._run_quiet
current=None
def logged(cmd,cwd,step,env=None):
    commands.append({'cell':current,'step':step,'cmd':cmd,'cwd':cwd})
    return real_run(cmd,cwd,step,env)
compiler._run_quiet=logged
metadata=read('manifest.json',{'host':HOST,'cpu':native['measurement_cpu'],
    'benchmark_base_revision':subprocess.check_output(['git','rev-parse','HEAD'],cwd=BENCH,text=True).strip(),
    'data_revision':subprocess.check_output(['git','rev-parse','origin/data'],cwd=BENCH,text=True).strip(),
    'config':CONFIG,'source_sha256':{},'targets':targets,'started':time.time()})
metadata['benchmark_revision']=subprocess.check_output(['git','rev-parse','HEAD'],cwd=BENCH,text=True).strip()
metadata['harness_sha256']={name:hashlib.sha256((BENCH/name).read_bytes()).hexdigest()
                          for name in ('benches.py','compile.py','runner.py')}
metadata['collector_sha256']=hashlib.sha256(Path(__file__).read_bytes()).hexdigest()
metadata['backend_linker_flags']=['-Wl,-plugin-opt=-disable-select-optimize=false']
for b,v in targets:
    src=BENCHES[b]['sources'][v]
    for filename in src if isinstance(src,tuple) else [src]:
        metadata['source_sha256'][filename]=hashlib.sha256((BENCH/filename).read_bytes()).hexdigest()
write('manifest.json',metadata)
status=read('status.json',{})
results=read('results.json',{})
saved=os.sched_getaffinity(0)
if MODE!='compile':os.sched_setaffinity(0,{metadata['cpu']})
try:
    for bench,variant in targets:
        current=f'{bench}/{variant}'
        binary=ROOT/bench/variant/'executable'
        binary.parent.mkdir(parents=True,exist_ok=True)
        if MODE=='compile' and status.get(current,{}).get('compiled'):continue
        if MODE!='compile' and not status.get(current,{}).get('compiled'):continue
        if MODE=='pilot' and status.get(current,{}).get('pilot',{}).get('exit_code')==0:continue
        if MODE=='measure' and status.get(current,{}).get('status') in ('complete','budget_limited'):continue
        started=time.time()
        try:
            if MODE=='compile':
                compiler.compile_cell(BENCHES[bench],VARIANTS[variant],BENCHES[bench]['sources'][variant],str(binary),lambda p:str(BENCH/p))
                status[current]={'compiled':True,'compile_started':started,'compile_finished':time.time(),
                                 'executable_sha256':hashlib.sha256(binary.read_bytes()).hexdigest()}
                row={'cell':current,'phase':'compiled'}
            elif MODE=='pilot':
                p=subprocess.run([str(binary)],capture_output=True,text=True,timeout=60,env=runner._runtime_env(variant))
                if p.returncode:raise RuntimeError(f'exit {p.returncode}: {p.stderr}{p.stdout}')
                status[current]['pilot']={'seconds':time.time()-started,'exit_code':p.returncode}
                row={'cell':current,'phase':'pilot',**status[current]['pilot']}
            elif MODE=='measure':
                assert status[current].get('pilot',{}).get('exit_code')==0
                r=runner.measure_executable(str(binary),runner._runtime_env(variant))
                assert r['results'] and all(code==0 for code in r['results'][0]['exit_codes'])
                results.setdefault(bench,{})[variant]=r
                status[current].update(status='budget_limited' if r['budget_limited'] else 'complete',started=started,finished=time.time())
                row={'cell':current,'phase':'measured','mean_seconds':r['results'][0]['mean'],
                     'samples':r['sample_count'],'warmups':r['warmup_runs'],'limited':r['budget_limited']}
            else:raise ValueError(MODE)
        except Exception as error:
            status.setdefault(current,{})[MODE+'_error']=str(error)
            row={'cell':current,'phase':MODE+'_failed','error':str(error)}
        print(json.dumps(row),flush=True)
        write('status.json',status);write('results.json',results);write('commands.json',commands)
finally:os.sched_setaffinity(0,saved)
metadata[MODE+'_finished']=time.time();write('manifest.json',metadata)
print(MODE.upper()+'_COMPLETE',flush=True)
