"""Check shared KOMA heading rhythm, overrides, references and page attachment."""
from pathlib import Path
import os
import shutil
import subprocess
import tempfile
import pdfplumber
from pypdf import PdfReader

ROOT = Path(__file__).resolve().parents[2]
HERE = Path(__file__).resolve().parent


def main():
    with tempfile.TemporaryDirectory(prefix='satz-headings-', dir=ROOT) as directory:
        output = Path(directory)
        def run(command, **kwargs):
            p = subprocess.run(command, capture_output=True, text=True, **kwargs)
            assert p.returncode == 0, p.stdout[-3000:] + p.stderr
            if command[0] == 'typst': assert not p.stderr.strip(), p.stderr
        def compile_source(name, text):
            path = output / (name + '.typ')
            path.write_text(text)
            run(['typst', 'compile', '--root', str(ROOT), str(path), str(path.with_suffix('.pdf'))])
            return path.with_suffix('.pdf')
        def find(pdf, text):
            for p in pdf.pages:
                matches = p.search(text, regex=False)
                if matches: return p.page_number, matches[0]
            raise AssertionError(text)
        src = (HERE / 'shared-headings.typ').read_text().replace('"../../lib.typ"', '"/lib.typ"')
        path = compile_source('shared', src)
        shutil.copy(HERE / 'shared-headings.tex', output / 'reference.tex')
        env = os.environ.copy()
        cache = Path(tempfile.gettempdir()) / 'satz-dfg-rhythm/tex-cache'
        cache.mkdir(parents=True, exist_ok=True)
        env.update(TEXMFVAR=str(cache), TEXMFCACHE=str(cache))
        run(['lualatex', '-interaction=batchmode', '-halt-on-error', 'reference.tex'], cwd=output, env=env)
        with pdfplumber.open(path) as actual, pdfplumber.open(output / 'reference.pdf') as reference:
            _, a0 = find(actual, 'BODYBEGIN')
            _, r0 = find(reference, 'BODYBEGIN')
            errors = []
            for marker in ['LEVELONE', 'BODYONE', 'LEVELTWO', 'BODYTWO', 'LEVELTHREE', 'BODYTHREE', 'STACKONE', 'STACKTWO', 'STACKBODY']:
                _, a = find(actual, marker)
                _, r = find(reference, marker)
                delta = abs((a['top'] - a0['top']) - (r['top'] - r0['top']))
                assert delta < .05, (marker, delta)
                errors.append(delta)
            print(f'Shared KOMA reference: maximum relative vertical error {max(errors):.4f} pt')
        base = '#import "/lib.typ": personal\n#show: personal.with(kind: "proposal", config: (toc: (depth: 0), page: (paper: "a6", margin: 12mm), '
        for level in range(1, 5):
            for height in (104, 112):
                path = compile_source(f'edge-{level}-{height}', base + '))\n' + f'#v({height}mm)\n' + '=' * level + ' EDGEHEADING <edge>\nFOLLOWINGBODY\nReference @edge.\n')
                with pdfplumber.open(path) as pdf:
                    assert find(pdf, 'EDGEHEADING')[0] == find(pdf, 'FOLLOWINGBODY')[0]
                assert PdfReader(path).outline
            gaps = []
            for above in (12, 32):
                path = compile_source(f'override-{level}-{above}', base + f'typography: (paragraph-spacing: 4pt), headings: (h{level}-above: {above}pt, h{level}-below: 6pt)))\n#v(20pt)\nPRECEDING\n\n' + '=' * level + ' TUNABLE\nFOLLOWING\n')
                with pdfplumber.open(path) as pdf:
                    p, previous = find(pdf, 'PRECEDING')
                    h, heading = find(pdf, 'TUNABLE')
                    b, following = find(pdf, 'FOLLOWING')
                    assert p == h == b
                    gaps.append((heading['top'] - previous['bottom'], following['top'] - heading['bottom']))
            assert abs(gaps[1][0] - gaps[0][0] - 20) < .02
            assert abs(gaps[1][1] - gaps[0][1]) < .02
        # A display equation interrupts a heading chain; before-spacing returns.
        for between in ['PROSE', '$ x = y $', '- LISTITEM', '+ ENUMITEM', '#table([CELL])']:
            path = compile_source('interruption', base + '))\n= FIRST\n' + between + '\n\n== SECOND\nAFTER\n')
            with pdfplumber.open(path) as pdf:
                assert find(pdf, 'SECOND')[1]['top'] - find(pdf, 'FIRST')[1]['bottom'] > 20
                if 'ITEM' in between:
                    token = 'LISTITEM' if 'LIST' in between else 'ENUMITEM'
                    assert find(pdf, 'SECOND')[1]['top'] - find(pdf, token)[1]['bottom'] > 10
        book = compile_source('book-rhythm', '''
#import "/lib.typ": book, book-mainmatter
#show: book.with(title: [Spacing specimen], author: [Satz], config: (page: (paper: "a6", margin: (left: 12mm, right: 12mm, top: 12mm, bottom: 12mm))))
#book-mainmatter[
= Chapter heading
Chapter opening paragraph.

== Subsection heading
Subsection following paragraph.

=== Lower heading
Lower following paragraph.

==== Small heading
Small following paragraph.
]
''')
        with pdfplumber.open(book) as pdf:
            for heading, preceding, following in [
                ('Subsection heading', 'Chapter opening paragraph.', 'Subsection following paragraph.'),
                ('Lower heading', 'Subsection following paragraph.', 'Lower following paragraph.'),
                ('Small heading', 'Lower following paragraph.', 'Small following paragraph.'),
            ]:
                page, h = find(pdf, heading)
                previous_page, before = find(pdf, preceding)
                following_page, after = find(pdf, following)
                assert page == previous_page == following_page
                above_gap = h['top'] - before['bottom']
                below_gap = after['top'] - h['bottom']
                assert above_gap > below_gap, (heading, above_gap, below_gap)
        print('Passed: shared KOMA rhythm, book subsection hierarchy, stacked headings, all-level page attachment, overrides, display interruption and bookmarks.')


if __name__ == '__main__':
    main()
