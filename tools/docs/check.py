#!/usr/bin/env python3
"""Compile complete published examples and check a built documentation site.

Use --package-path with an isolated published package directory when local
@preview overrides are present. Build the site with zensical first.
"""
import argparse
from html.parser import HTMLParser
from pathlib import Path
import re
import subprocess
import tempfile
from urllib.parse import unquote, urlsplit

ROOT = Path(__file__).resolve().parents[2]


class Page(HTMLParser):
    def __init__(self, path):
        super().__init__()
        self.ids = set()
        self.links = []
        self.headings = 0
        self.lang = None
        self.feed(path.read_text())

    def handle_starttag(self, tag, attrs):
        attrs = dict(attrs)
        if 'id' in attrs:
            self.ids.add(attrs['id'])
        if tag == 'a' and 'href' in attrs:
            self.links.append(attrs['href'])
        if tag == 'h1':
            self.headings += 1
        if tag == 'html':
            self.lang = attrs.get('lang')


def main():
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument('--package-path', type=Path)
    args = parser.parse_args()
    count = 0
    with tempfile.TemporaryDirectory(prefix='satz-docs-') as temporary:
        for source in sorted((ROOT / 'docs/site').rglob('*.md')):
            for number, code in enumerate(re.findall(r'```typst\n(.*?)```', source.read_text(), re.S)):
                if '#import "@preview/satz:0.1.1"' not in code or len(code.splitlines()) <= 3:
                    continue
                path = Path(temporary) / f'{source.stem}-{number}.typ'
                path.write_text(code)
                command = ['typst', 'compile']
                if args.package_path:
                    command += ['--package-path', str(args.package_path.resolve())]
                subprocess.run(command + [str(path), str(path.with_suffix('.pdf'))], check=True)
                count += 1
    site = ROOT / 'site'
    pages = {path.resolve(): Page(path) for path in site.rglob('*.html')}
    assert pages, 'Build the documentation site first.'
    for path, page in pages.items():
        if path.name != '404.html':
            assert page.lang == 'en', f'Missing document language: {path}'
            assert page.headings == 1, f'Expected one page heading: {path}'
        for link in page.links:
            url = urlsplit(link)
            if url.scheme or url.netloc:
                continue
            target = unquote(url.path)
            if target.startswith('/satz/'):
                target = target[len('/satz/'):]
                destination = site / target
            elif target.startswith('/'):
                destination = site / target.lstrip('/')
            else:
                destination = path.parent / target if target else path
            if destination.is_dir():
                destination /= 'index.html'
            destination = destination.resolve()
            assert destination.exists(), f'Broken link in {path}: {link}'
            if url.fragment and destination in pages:
                assert unquote(url.fragment) in pages[destination].ids, f'Broken anchor in {path}: {link}'
    print(f'Compiled {count} complete examples; checked links, anchors, language and headings on {len(pages)} pages.')


if __name__ == '__main__':
    main()
