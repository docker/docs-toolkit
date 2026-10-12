#!/usr/bin/env python3
import json
import os
from pathlib import Path
import subprocess
import tempfile

root = Path(__file__).resolve().parent.parent
cases = json.loads((root / 'fixtures/rules.json').read_text())
rules = {p.stem for p in (root / 'styles/Docker').glob('*.yml')}
if rules != set(cases):
    raise SystemExit(f'Rule coverage mismatch: missing={rules - set(cases)}, extra={set(cases) - rules}')

with tempfile.TemporaryDirectory(prefix='docker-rule-tests-') as temporary:
    directory = Path(temporary)
    for rule, case in sorted(cases.items()):
        config = directory / '.vale.ini'
        config.write_text(f'''StylesPath = {root / 'styles'}
MinAlertLevel = suggestion
[*.md]
Docker.{rule} = YES
BlockIgnores = (?s) *<!--.*?-->, (?m)^ *>[^\\n]*
TokenIgnores = (?:[a-z]+[A-Z][a-zA-Z0-9]*|[a-zA-Z]+_[a-zA-Z0-9_]+)
''')
        bad = case['bad']
        variants = {
            'positive': (bad, True),
            'negative': (case['good'], False),
            'inline-code': (f'`{bad}`', False),
            'fenced-code': (f'```text\n{bad}\n```', False),
            'quotation': (f'> {bad}', False),
            'directive': (f'<!-- {bad} -->', False),
            'identifier': ('dockerCompose githubActions utilizeAdapter', False),
        }
        for label, (text, expected) in variants.items():
            source = directory / 'case.md'
            source.write_text(text + '\n')
            result = subprocess.run([os.environ.get('VALE', 'vale'), '--no-global',
                f'--config={config}', '--output=JSON', str(source)],
                capture_output=True, text=True)
            if result.returncode not in (0, 1):
                raise SystemExit(f'{rule}/{label}: Vale failed: {result.stderr} {result.stdout}')
            findings = [item for items in json.loads(result.stdout).values() for item in items]
            if bool(findings) != expected or any(f['Check'] != f'Docker.{rule}' for f in findings):
                raise SystemExit(f'{rule}/{label}: expected findings={expected}, got {findings}')
    print(f'Passed positive, negative, and exclusion cases for {len(cases)} Docker rules.')
