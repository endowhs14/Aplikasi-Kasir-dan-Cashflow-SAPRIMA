#!/usr/bin/env python3
"""Run actual separate Dart processes; exit(77) simulates death without closing SQLite."""
import subprocess
import tempfile
from pathlib import Path

with tempfile.TemporaryDirectory(prefix='saprima-crash-') as directory:
    for phase, expected in [('seed', 0), ('before_commit', 77), ('verify_rollback', 0),
                            ('after_commit', 77), ('verify_committed', 0),
                            ('replay', 0), ('verify_committed', 0)]:
        result = subprocess.run(['dart', 'run', 'tool/crash_probe.dart', directory, phase])
        if result.returncode != expected:
            raise SystemExit(f'{phase}: expected {expected}, got {result.returncode}')
print('PASS process-crash/reopen/replay fixture (7 phases)')
