from pathlib import Path
import hashlib,json,os,platform,resource,shutil,subprocess,sys,time,traceback
ROOT=Path(__file__).resolve().parent
BENCH=ROOT/'benchmark'
SOURCE=Path('/tmp/reussir-full-tbi-20261111')
OUT=ROOT/'results'; OUT.mkdir(exist_ok=True)
sys.path.insert(0,str(BENCH))
from config import CONFIG
from benches import BENCHES,VARIANTS
import compile as compiler
import runner
MODE=sys.argv[1]
def digest(p): return hashlib.sha256(Path(p).read_bytes()).hexdigest()
def save(name,data):
 p=OUT/name; tmp=p.with_suffix('.tmp'); tmp.write_text(json.dumps(data,indent=2)+'\n'); tmp.replace(p)
def read(name,default):
 p=OUT/name; return json.loads(p.read_text()) if p.exists() else default
baseline=json.loads((ROOT/'baseline-manifest.json').read_text())
CONFIG.update(baseline['config'])
CONFIG.update({'reussir-compiler':str(SOURCE/'build/bin/rrc'),'reussir-src':str(SOURCE),'reussir-libs':str(ROOT/'runtime-xlto/release'),'reussir-rcgmp-runtime':str(SOURCE/'build/lib/libRCGMPRuntime.a'),'runs':10,'warmup-runs':5,'compile-timeout-seconds':300,'case-time-budget-seconds':300})
for key in list(os.environ):
 if key.startswith('NIX_ENFORCE_NO_NATIVE'): os.environ[key]='0'
os.environ['REUSSIR_RUSTC']=subprocess.check_output(['sed','-n','s/^REUSSIR_RUSTC_PATH:FILEPATH=//p',str(SOURCE/'build/CMakeCache.txt')],text=True).strip()
os.environ['REUSSIR_RUSTC_DEPS']=str(SOURCE/'build/target-rt/release/deps')
os.environ['REUSSIR_FFI_CACHE_DIR']=str(ROOT/'polyffi-cache')
# Use the same GMP as the compiler shell, with an explicit run path in linked cells.
gmp=next(p for p in os.environ['LD_LIBRARY_PATH'].split(':') if 'gmp-' in p or 'gmp-with-cxx-' in p)
os.environ['NIX_LDFLAGS']=os.environ.get('NIX_LDFLAGS','')+' -L'+gmp
resource.setrlimit(resource.RLIMIT_STACK,(resource.RLIM_INFINITY,resource.RLIM_INFINITY))
targets=sorted((b,'reussir') for b in BENCHES if 'reussir' in BENCHES[b]['sources'])
assert len(targets)==30
revision=subprocess.check_output(['git','-C',str(SOURCE),'rev-parse','HEAD'],text=True).strip()
assert revision.startswith('c55dc218')
manifest=read('manifest.json',{'host':platform.node(),'architecture':platform.machine(),'started':time.time(),'benchmark_revision':'1cf406dffa22b8bfc65eeb30241e8154f27a5505','data_revision':'53904ff','reussir_revision':revision,'measurement_cpu':19,'config':CONFIG.copy(),'targets':targets,'target_count':len(targets),'source_sha256':{},'harness_sha256':{p:digest(BENCH/p) for p in ['benches.py','compile.py','runner.py','config.py','config.json']},'reussir_compiler_sha256':digest(SOURCE/'build/bin/rrc'),'runtime_archive_sha256':digest(Path(CONFIG['reussir-libs'])/'libreussir_rt.a'),'rcgmp_runtime_sha256':digest(CONFIG['reussir-rcgmp-runtime']),'library_source_sha256':{str(p.relative_to(SOURCE)):digest(p) for p in (SOURCE/'library').rglob('*') if p.is_file()},'compiler_environment':{k:os.environ.get(k) for k in ['REUSSIR_RUSTC','REUSSIR_RUSTC_DEPS','LD_LIBRARY_PATH','NIX_LDFLAGS','RUSTC_WRAPPER']},'runtime_source_revision':'015e63cc9b15ea5ac7a5f5d2caa257fb6ef278f7','runtime_unchanged_by_fix':True,'runtime_build_flags':{'RUSTFLAGS':'-Clinker-plugin-lto -Clink-arg=-fuse-ld=lld','CFLAGS':'-flto=thin -DMI_MAX_ALIGN_SIZE=8'},'starting_load':os.getloadavg()})
for b,v in targets:
 for p in BENCHES[b]['sources'][v]: manifest['source_sha256'][p]=digest(BENCH/p)
status=read('status.json',{});results=read('results.json',{});commands=read('commands.json',[])
original_run=compiler._run_quiet
current=None
def logged(cmd,cwd,step,env=None):
 commands.append({'cell':current,'step':step,'cmd':cmd,'cwd':cwd})
 try: return original_run(cmd,cwd,step,env)
 finally: save('commands.json',commands)
compiler._run_quiet=logged
save('manifest.json',manifest)
if MODE=='measure':
 assert all(status.get(b+'/'+v,{}).get('compiled') for b,v in targets)
 os.sched_setaffinity(0,{19})
 manifest['measurement_started']=time.time();manifest['measurement_start_load']=os.getloadavg();save('manifest.json',manifest)
for index,(b,v) in enumerate(targets,1):
 current=b+'/'+v;binary=ROOT/'bin'/b;binary.parent.mkdir(exist_ok=True)
 if MODE=='compile' and status.get(current,{}).get('compiled'):continue
 if MODE=='measure' and status.get(current,{}).get('status') in ['complete','budget_limited','budget_exhausted']:continue
 print(index,len(targets),MODE,current,flush=True);started=time.time()
 try:
  if MODE=='compile':
   compiler.compile_cell(BENCHES[b],VARIANTS[v],BENCHES[b]['sources'][v],str(binary),lambda p:str(BENCH/p))
   status[current]={'compiled':True,'compile_started':started,'compile_finished':time.time(),'binary_sha256':digest(binary)}
  else:
   assert digest(binary)==status[current]['binary_sha256']
   env=runner._runtime_env(v)
   env.pop('LD_LIBRARY_PATH',None)
   env.pop('LD_PRELOAD',None)
   pilot=subprocess.run([str(binary)],capture_output=True,text=True,timeout=300,env=env)
   (OUT/(b+'.stdout')).write_text(pilot.stdout);(OUT/(b+'.stderr')).write_text(pilot.stderr)
   assert pilot.returncode==0,(b,pilot.returncode,pilot.stderr,pilot.stdout)
   payload=runner.measure_executable(str(binary),env)
   if payload['results']:assert all(c==0 for c in payload['results'][0]['exit_codes'])
   results.setdefault(b,{})[v]=payload
   state='budget_exhausted' if payload['sample_count']==0 else ('budget_limited' if payload['budget_limited'] else 'complete')
   status[current].update(status=state,started=started,finished=time.time(),correctness_exit_code=pilot.returncode)
   print('RESULT',b,payload['sample_count'],payload.get('results',[{}])[0].get('mean') if payload['results'] else None,flush=True)
 except Exception as error:
  status.setdefault(current,{}).update(status='error',error=str(error),finished=time.time())
  (OUT/(b+'.error.log')).write_text(traceback.format_exc())
  save('status.json',status);save('results.json',results)
  raise
 save('status.json',status);save('results.json',results)
manifest[MODE+'_finished']=time.time()
if MODE=='measure':manifest['finished']=time.time();manifest['ending_load']=os.getloadavg()
save('manifest.json',manifest)
print(MODE.upper()+'_COMPLETE',flush=True)
