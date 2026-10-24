#!/usr/bin/env python3
"""Copy a self-contained macOS template to a new directory; never overwrite a project."""
import argparse
from pathlib import Path
import json
import re
import shutil


def main():
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument('destination', type=Path)
    parser.add_argument('--name', default='Clothesline Demo')
    parser.add_argument('--bundle-id', default='local.clothesline.demo')
    parser.add_argument('--symbol', default='square.stack')
    args = parser.parse_args()
    destination = args.destination.expanduser().absolute()
    if destination.exists():
        parser.error(f'destination already exists: {destination}')
    if not args.name.strip() or any(c in '/\\' or ord(c) < 32 for c in args.name) or args.name in ('.', '..'):
        parser.error('name must be a non-empty application filename, without path separators or newlines')
    if not re.fullmatch(r'[A-Za-z][A-Za-z0-9-]*(?:\.[A-Za-z0-9][A-Za-z0-9-]*)+', args.bundle_id):
        parser.error('bundle-id must be a reverse-DNS identifier')
    if not re.fullmatch(r'[a-z0-9.]+', args.symbol):
        parser.error('symbol must be an SF Symbols name')
    source = Path(__file__).resolve().parent.parent / 'assets' / 'swiftui-appkit'
    shutil.copytree(source, destination, ignore=shutil.ignore_patterns('.build', 'dist', '.DS_Store', '__pycache__'))
    config = destination / 'Sources' / 'ClotheslineApp' / 'Demo.swift'
    text = config.read_text()
    # Inputs have no control characters; JSON escapes quotes and backslashes for Swift.
    def swift_string(value):
        return json.dumps(value, ensure_ascii=False)
    replacements = {'appName': args.name, 'bundleID': args.bundle_id, 'menuSymbol': args.symbol}
    lines = text.splitlines()
    for index, line in enumerate(lines):
        for key, value in replacements.items():
            if line.startswith(f'    static let {key} = '):
                lines[index] = f'    static let {key} = {swift_string(value)}'
    text = '\n'.join(lines) + '\n'
    config.write_text(text)
    settings = destination / 'app-config.json'
    settings.write_text(json.dumps({'name': args.name, 'bundle_id': args.bundle_id}, ensure_ascii=False, indent=2) + '\n')
    print(f'Created: {destination}')
    print('Build: swift build')
    print('Test: swift test')
    print('Package: python3 scripts/build_app.py')


if __name__ == '__main__':
    main()
