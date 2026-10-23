#!/usr/bin/env python3
"""Compile complete published examples and check a built documentation site.

The documentation tutorials compile against the current local 0.2.0 source.
Build the site with npm run build first.
"""
import argparse
from html.parser import HTMLParser
from pathlib import Path
import re
import struct
import subprocess
import tempfile
from urllib.parse import unquote, urlsplit
import zlib

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
    parser.parse_args()
    count = 0
    with tempfile.TemporaryDirectory(prefix='satz-docs-') as temporary:
        package_path = Path(temporary) / 'packages'
        local_package = package_path / 'local' / 'satz' / '0.2.0'
        local_package.parent.mkdir(parents=True)
        local_package.symlink_to(ROOT, target_is_directory=True)
        for source in sorted((ROOT / 'docs/site').rglob('*.md')):
            for number, code in enumerate(re.findall(r'```typst\n(.*?)```', source.read_text(), re.S)):
                if '#import "@local/satz:0.2.0"' not in code or len(code.splitlines()) <= 3:
                    continue
                path = Path(temporary) / f'{source.stem}-{number}.typ'
                path.write_text(code)
                # Standalone documentation snippets may name a reader-supplied
                # image. A tiny valid placeholder lets this check verify the
                # Typst syntax and Satz API without shipping example binaries.
                def png_chunk(kind, data):
                    return (
                        struct.pack('>I', len(data))
                        + kind
                        + data
                        + struct.pack('>I', zlib.crc32(kind + data) & 0xffffffff)
                    )

                placeholder_png = (
                    b'\x89PNG\r\n\x1a\n'
                    + png_chunk(b'IHDR', struct.pack('>IIBBBBB', 1, 1, 8, 6, 0, 0, 0))
                    + png_chunk(b'IDAT', zlib.compress(b'\x00\xff\xff\xff\xff'))
                    + png_chunk(b'IEND', b'')
                )
                for image_name in re.findall(r'image\(\s*["\']([^"\']+)["\']', code):
                    image_path = (Path(temporary) / image_name).resolve()
                    if image_path.is_relative_to(Path(temporary).resolve()):
                        image_path.parent.mkdir(parents=True, exist_ok=True)
                        image_path.write_bytes(placeholder_png)
                # Included entry/chapter snippets are often shown separately
                # from their companion source files. Empty files keep this
                # syntax check focused on the displayed main-file example.
                for include_name in re.findall(r'#include\s+["\']([^"\']+)["\']', code):
                    include_path = (Path(temporary) / include_name).resolve()
                    if include_path.is_relative_to(Path(temporary).resolve()):
                        include_path.parent.mkdir(parents=True, exist_ok=True)
                        include_path.touch(exist_ok=True)
                command = ['typst', 'compile', '--package-path', str(package_path)]
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
