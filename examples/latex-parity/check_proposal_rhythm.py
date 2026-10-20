"""Measure proposal baseline and heading gaps against shared Satz defaults.

Optional --latex-reference PATH compares with a compiled emtpb specimen.
"""
from pathlib import Path
import argparse
import json
import subprocess
import tempfile
import pdfplumber

ROOT = Path(__file__).resolve().parents[2]


def metrics(path):
    with pdfplumber.open(path) as document:
        words = [dict(w, page=p.page_number) for p in document.pages for w in p.extract_words()]
        markers = [next(w for w in words if w['text'] == key) for key in ['BASELINEONE', 'BASELINETWO', 'BASELINETHREE']]
        assert len({w['page'] for w in markers}) == 1
        baseline = markers[1]['top'] - markers[0]['top']
        gaps = []
        for page in document.pages:
            lines = page.extract_text_lines()
            for index, line in enumerate(lines[:-1]):
                if line['text'].endswith(('Reference protocol', 'Anticipated total duration of the project')):
                    gaps.append(lines[index+1]['top'] - line['bottom'])
        return {'pages': len(document.pages), 'baseline_pt': baseline, 'heading_ink_gaps_pt': gaps}


def main():
    parser = argparse.ArgumentParser()
    parser.add_argument('--latex-reference', type=Path)
    args = parser.parse_args()
    with tempfile.TemporaryDirectory(prefix='satz-rhythm-', dir=ROOT) as directory:
        output = Path(directory)
        source = (ROOT / 'examples/latex-parity/proposal-rhythm.typ').read_text().replace('"../../lib.typ"', '"/lib.typ"')

        def compile_doc(name, text):
            path = output / (name + '.typ')
            path.write_text(text)
            run = subprocess.run(['typst', 'compile', '--root', str(ROOT), str(path), str(path.with_suffix('.pdf'))], text=True, capture_output=True)
            assert run.returncode == 0 and not run.stderr.strip(), run.stderr
            return metrics(path.with_suffix('.pdf'))

        actual = compile_doc('proposal', source)
        native = compile_doc('native', '#import "/lib.typ": defaults\n#set text(font: "Arial", size: 11pt)\n#set par(leading: defaults.typography.leading)\nBASELINEONE \\ BASELINETWO \\ BASELINETHREE')
        assert abs(actual['baseline_pt'] - native['baseline_pt']) < 0.01, (actual, native)
        assert len(actual['heading_ink_gaps_pt']) == 2
        assert min(actual['heading_ink_gaps_pt']) >= 3, actual
        assert actual['baseline_pt'] >= 13.2, actual
        custom = compile_doc('custom', source.replace('applicant:', 'config: (typography: (leading: 0.8em)),\n  applicant:', 1))
        assert abs(custom['baseline_pt'] - actual['baseline_pt'] - 11 * (0.8 - 0.65)) < 0.01
        if args.latex_reference:
            reference = metrics(args.latex_reference)
            print(json.dumps({'satz': actual, 'latex_reference': reference}, indent=2))
        else:
            print(json.dumps({'satz': actual}, indent=2))
    print('Passed: proposal baseline matches shared defaults, heading text does not overlap, minimum leading and config override are verified.')


if __name__ == '__main__':
    main()
