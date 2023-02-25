import os
import subprocess
import threading
import time

from datetime import datetime
from pathlib import Path

from watchdog.events import PatternMatchingEventHandler
from watchdog.observers import Observer

project_root = Path(__file__).parent.parent
make_log_file = project_root / 'log' / 'make.log'
test_log_file = project_root / 'log' / 'test.log'

def make_wasm(e):
    p = subprocess.run(['make', 'wasm'], capture_output=True, cwd=project_root, text=True,
                       env={**os.environ, 'WAM_DEBUG': '1'})
    f = make_log_file.open('a')

    rel_path = str(Path(e.src_path).relative_to(project_root))
    timestamp = datetime.utcnow().strftime('%Y-%m-%d %H:%M:%S')

    f.write(f'\n{timestamp} {rel_path} {e.event_type}\n')

    f.write('stdout:\n')
    f.write(p.stdout)

    if p.stderr:
        f.write('\nstderr:\n')
        f.write(p.stderr)

    f.close()

def test_wasm(e):
    subprocess.run(['pkill', 'pytest'])
    threading.Thread(target=start_test, args=(e,)).start()

def start_test(e):
    f = test_log_file.open('ab', buffering=0)

    rel_path = str(Path(e.src_path).relative_to(project_root))
    timestamp = datetime.utcnow().strftime('%Y-%m-%d %H:%M:%S')
    f.write(f'\n{timestamp} {rel_path} {e.event_type}\n'.encode())

    p = subprocess.run(['stdbuf', '-i0', '-o0', '-e0', 'make', 'test'],
                       stdout=f, stderr=f, cwd=project_root)

    f.close()

wam_handler = PatternMatchingEventHandler(patterns=['*.wam'], ignore_patterns=['*#*'])
wasm_handler = PatternMatchingEventHandler(patterns=['*.wasm'])
test_handler = PatternMatchingEventHandler(patterns=['test_*.py'])

wam_handler.on_modified = make_wasm
wasm_handler.on_modified = test_wasm
test_handler.on_modified = test_wasm

o = Observer()

wam_watch = o.schedule(wam_handler, project_root, recursive=False)
wasm_watch = o.schedule(wasm_handler, project_root, recursive=False)
test_watch = o.schedule(test_handler, project_root / 'test', recursive=True)

o.start()

try:
    time.sleep(365*24*60*60)

except KeyboardInterrupt:
    ...
