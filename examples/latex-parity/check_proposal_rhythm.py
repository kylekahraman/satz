"""Compare DFG layout with a pinned, independently compiled KOMA reference.

Needs Typst, LuaLaTeX (TeX Live), Arial, pdfplumber and pypdf. No network needed.
Use --output DIR to retain the paired PDFs for visual review.
"""
from pathlib import Path
import argparse
import os
import shutil
import subprocess
import tempfile

import pdfplumber
from pypdf import PdfReader

ROOT = Path(__file__).resolve().parents[2]
HERE = Path(__file__).resolve().parent


def run(command, cwd=None, env=None):
    result = subprocess.run(command, cwd=cwd, env=env, capture_output=True, text=True)
    assert result.returncode == 0, result.stdout[-4000:] + result.stderr
    if command[0] == 'typst':
        assert not result.stderr.strip(), result.stderr


def compare(latex, typst):
    with pdfplumber.open(latex) as reference, pdfplumber.open(typst) as actual:
        assert len(reference.pages) == len(actual.pages)
        worst = 0
        for rp, ap in zip(reference.pages, actual.pages):
            rl, al = rp.extract_text_lines(), ap.extract_text_lines()
            assert len(rl) == len(al), (len(rl), len(al))
            for r, a in zip(rl, al):
                delta = abs(r['top'] - a['top'])
                worst = max(worst, delta)
                assert delta < .02, (r['text'], a['text'], delta)
                assert abs(r['bottom'] - a['bottom']) < .02
            # Right-aligned, correctly counted header on every physical page.
            assert f'page {ap.page_number} of max. 17' in al[0]['text']
            assert abs(rl[0]['x1'] - al[0]['x1']) < .02
            # The hanging indent on wrapped headings must match, too.
            for r, a in zip(rl, al):
                if r['text'].startswith('alignment of the heading text'):
                    assert abs(r['x0'] - a['x0']) < .02
            rr = [l for l in rp.lines if l['width'] > 300]
            ar = [l for l in ap.lines if l['width'] > 300]
            assert len(rr) == len(ar)
            for r, a in zip(rr, ar):
                assert abs(r['top'] - a['top']) < .02
        return len(actual.pages), worst


def main():
    parser = argparse.ArgumentParser()
    parser.add_argument('--output', type=Path)
    args = parser.parse_args()
    with tempfile.TemporaryDirectory(prefix='satz-rhythm-') as directory:
        output = args.output.resolve() if args.output else Path(directory)
        output.mkdir(parents=True, exist_ok=True)
        shutil.copy(HERE / 'reference/proposal.cls', output / 'proposal.cls')
        env = os.environ.copy()
        cache = Path(tempfile.gettempdir()) / 'satz-dfg-rhythm/tex-cache'
        cache.mkdir(parents=True, exist_ok=True)
        env.update(TEXMFVAR=str(cache), TEXMFCACHE=str(cache))
        for name in ['proposal-rhythm', 'proposal-headings']:
            shutil.copy(HERE / (name + '.tex'), output / (name + '.tex'))
            for _ in range(2):
                run(['lualatex', '-interaction=batchmode', '-halt-on-error', name + '.tex'], cwd=output, env=env)
            target = output / (name + '-typst.pdf')
            run(['typst', 'compile', '--root', str(ROOT), str(HERE / (name + '.typ')), str(target)])
            pages, error = compare(output / (name + '.pdf'), target)
            print(f'{name}: {pages} pages; maximum vertical error {error:.4f} pt')
            assert PdfReader(target).outline, 'Heading bookmarks must survive rendering.'
        # A caller's explicit leading override must still change the baseline.
        source = (HERE / 'proposal-rhythm.typ').read_text().replace('"../../lib.typ"', '"/lib.typ"')
        source = source.replace('applicant:', 'config: (typography: (leading: 0.8em)), applicant:', 1)
        with tempfile.TemporaryDirectory(prefix='satz-rhythm-override-', dir=ROOT) as override:
            path = Path(override) / 'custom.typ'
            path.write_text(source)
            run(['typst', 'compile', '--root', str(ROOT), str(path), str(path.with_suffix('.pdf'))])
            with pdfplumber.open(path.with_suffix('.pdf')) as pdf:
                words = [w for p in pdf.pages for w in p.extract_words()]
                one, two = [next(w for w in words if w['text'] == key) for key in ['BASELINEONE', 'BASELINETWO']]
                assert abs(two['top'] - one['top'] - (1467 / 2048 * 11 + .8 * 11)) < .01
    print('Passed: title, header, four heading levels, stacked/wrapped/page-start headings, body rhythm, list/table rows and overrides.')


if __name__ == '__main__':
    main()
