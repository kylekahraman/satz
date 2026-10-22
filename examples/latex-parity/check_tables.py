"""Verify table configuration and pagination in the rendered PDF."""

from pathlib import Path
import subprocess
import tempfile

import pymupdf as fitz


ROOT = Path(__file__).resolve().parents[2]


def compile_pdf(folder, name, size, inset):
    source = folder / f"{name}.typ"
    source.write_text(
        f'#import "{ROOT}/report/template.typ": report\n'
        '#show: report.with(config: (toc: (depth: 0), '
        'page: (paper: "a6", margin: 12mm), '
        f'tables: (font-size: {size}pt, inset: (x: {inset}pt, y: 4pt))))\n'
        '#table(columns: (40mm, 30mm), [PADANCHOR], [OTHER])\n'
        '#table(columns: 1, inset: 2pt, text(size: 13pt)[LOCALOVERRIDE])\n'
        '#pagebreak()\n'
        '#table(columns: (40mm, 30mm), table.header([REPEATHEADER], [VALUE]),\n'
        + '\n'.join(f'[ROW{i:03d}], [{i}],' for i in range(60))
        + '\n)\n'
    )
    output = source.with_suffix('.pdf')
    subprocess.run(['typst', 'compile', '--root', '/', str(source), str(output)], check=True)
    return fitz.open(output)


def span(document, needle):
    for page in document:
        for block in page.get_text('dict')['blocks']:
            for line in block.get('lines', []):
                for item in line['spans']:
                    if needle in item['text']:
                        return item
    raise AssertionError(f'Missing text: {needle}')


def main():
    with tempfile.TemporaryDirectory(prefix='satz-table-check-') as directory:
        folder = Path(directory)
        with compile_pdf(folder, 'small', 8, 3) as small, compile_pdf(folder, 'large', 12, 11) as large:
            first, second = span(small, 'PADANCHOR'), span(large, 'PADANCHOR')
            assert abs(first['size'] - 8) < 0.01
            assert abs(second['size'] - 12) < 0.01
            assert abs(second['bbox'][0] - first['bbox'][0] - 8) < 0.05
            assert abs(span(large, 'LOCALOVERRIDE')['size'] - 13) < 0.01
            for document in (small, large):
                text = '\n'.join(page.get_text() for page in document)
                assert all(text.count(f'ROW{i:03d}') == 1 for i in range(60))
                pages = [p for p in document if 'ROW' in p.get_text()]
                assert len(pages) > 1
                assert all('REPEATHEADER' in p.get_text() for p in pages)
    print('Passed: table font, cell padding, local override, repeated headers, all 60 rows.')


if __name__ == '__main__':
    main()
