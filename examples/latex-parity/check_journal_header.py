"""Verify the entry-opening gap belongs to the journal header only."""
from pathlib import Path
import subprocess
import tempfile
import pdfplumber

ROOT = Path(__file__).resolve().parents[2]


def main():
    with tempfile.TemporaryDirectory(prefix='satz-journal-header-', dir=ROOT) as directory:
        output = Path(directory)
        def compile_doc(name, source):
            path = output / (name + '.typ')
            path.write_text(source)
            p = subprocess.run(['typst', 'compile', '--root', str(ROOT), str(path), str(path.with_suffix('.pdf'))], capture_output=True, text=True)
            assert p.returncode == 0 and not p.stderr.strip(), p.stderr
            return pdfplumber.open(path.with_suffix('.pdf'))
        def locate(pdf, text):
            for page in pdf.pages:
                matches = page.search(text, regex=False)
                if matches: return page.page_number, matches[0]
            raise AssertionError(text)
        for mode in ['koma', 'native']:
            for opening in ['== FIRSTHEADING\nBODYONE', 'FIRSTPROSE', '- FIRSTITEM']:
                documents = []
                for gap in [18, 36]:
                    source = f'''#import "/lib.typ": journal-entry
#show: journal-entry.with(title: "ENTRYTITLE", date: "DATEVALUE", keywords: "KEYWORD", config: (
 journal: (header-below: {gap}pt),
 headings: (spacing: "{mode}", h2-size: 14pt, h2-above: 1.5em, h2-below: 0.65em),
))
{opening}

== LATERHEADING
BODYTWO

== FINALHEADING
BODYTHREE
#pagebreak()
CONTINUATION
'''
                    with compile_doc(f'{mode}-{gap}-{len(opening)}', source) as pdf:
                        assert len(pdf.pages) == 2
                        assert 'CONTINUATION' in pdf.pages[1].extract_text()
                        date_page, date = locate(pdf, 'DATEVALUE')
                        token = 'FIRSTHEADING' if 'FIRSTHEADING' in opening else 'FIRSTPROSE' if 'FIRSTPROSE' in opening else 'FIRSTITEM'
                        first_page, first = locate(pdf, token)
                        assert date_page == first_page, 'Header must stay with first content.'
                        visible_gap = first['top'] - date['bottom']
                        assert visible_gap >= 12, (mode, token, visible_gap)
                        _, later = locate(pdf, 'LATERHEADING')
                        _, final = locate(pdf, 'FINALHEADING')
                        _, body = locate(pdf, 'BODYTWO')
                        documents.append((visible_gap, final['top'] - body['bottom'], later['top'] - first['top']))
                assert abs(documents[1][0] - documents[0][0] - 18) < .05, documents
                assert abs(documents[1][1] - documents[0][1]) < .05, 'Later heading spacing changed.'
        print('Passed: one configurable opening gap for headings/prose/lists, both spacing modes, header attachment and unchanged later heading spacing.')


if __name__ == '__main__':
    main()
