"""Demonstrate that paragraph spacing is not extra line leading."""
from pathlib import Path
import subprocess

import fitz

ROOT = Path(__file__).resolve().parents[2]
OUTPUT = Path(__file__).resolve().parent / 'output'


def baseline(page, marker):
    return next(span['origin'][1] for block in page.get_text('dict')['blocks']
                for line in block.get('lines', []) for span in line['spans']
                if span['text'] == marker)


def main():
    OUTPUT.mkdir(exist_ok=True)
    measurements = []
    for spacing in (0.52, 0.7, 1.45):
        path = OUTPUT / f'paragraph-rhythm-{spacing}.typ'
        source = '#import "/lib.typ": report\n#show: report.with(config: (toc: (depth: 0), typography: ('
        source += f'font: "STIX Two Text", size: 11pt, leading: 0.75em, paragraph-spacing: {spacing}em)))\n'
        source += 'FIRSTLINE\\\nSECONDLINE\n\nNEXTPAR\n'
        path.write_text(source)
        subprocess.run(['typst', 'compile', '--root', str(ROOT), str(path), str(path.with_suffix('.pdf'))], check=True)
        with fitz.open(path.with_suffix('.pdf')) as document:
            page = document[0]
            line_gap = baseline(page, 'SECONDLINE') - baseline(page, 'FIRSTLINE')
            paragraph_gap = baseline(page, 'NEXTPAR') - baseline(page, 'SECONDLINE')
            measurements.append((line_gap, paragraph_gap))
    assert measurements[0][1] < measurements[0][0]
    assert measurements[1][1] < measurements[1][0]
    assert abs(measurements[1][1] - measurements[0][1] - (.7 - .52) * 11) < .05
    assert abs(measurements[2][1] - measurements[2][0] - (1.45 - .75) * 11) < .05
    print('Passed: paragraph spacing replaces the inter-paragraph gap rather than adding to leading; undersized values tighten paragraph breaks.')
    for spacing, (line_gap, paragraph_gap) in zip((.52, .7, 1.45), measurements):
        print(f'{spacing}em: line baseline {line_gap:.3f}pt; paragraph baseline {paragraph_gap:.3f}pt')


if __name__ == '__main__':
    main()
