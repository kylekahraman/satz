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
        title = "Figure 5 Pooled Mahalanobis Recovery, Cross-Visibility RSA, and State Geometry"
        for name, value in [('short', 'ENTRYTITLE'), ('long', title), ('very-long', title + ' with additional validation across independent measurement sessions')]:
            source = f'''#import "/lib.typ": journal-entry
#show: journal-entry.with(title: "{value}", date: "Sunday, 18/10/26", config: (
 page: (paper: "iso-b5", margin: (left: 20mm, right: 20mm, top: 25mm, bottom: 25mm)),
))
== FIRSTHEADING
BODYONE
#pagebreak()
CONTINUATION
#pagebreak()
FINALPAGE
'''
            with compile_doc('running-' + name, source) as pdf:
                assert len(pdf.pages) == 3
                for page in pdf.pages[1:]:
                    header = page.crop((0, 0, float(page.width), 60))
                    date = header.search('Sunday, 18/10/26', regex=False)
                    assert len(date) == 1, header.extract_text()
                    date = date[0]
                    assert abs(date['x1'] - (page.width - 20 * 72 / 25.4)) < .1
                    title_words = [w for w in header.extract_words() if w['x0'] < date['x0'] - 1]
                    assert title_words
                    assert abs(min(w['top'] for w in title_words) - date['top']) < .05, 'Date must align to the first title line.'
                    assert max(w['x1'] for w in title_words) <= date['x0'] - 8.9, (name, title_words, date)
                    if name == 'very-long':
                        assert len({round(w['top'], 1) for w in title_words}) >= 2
                    body = page.search('CONTINUATION' if page.page_number == 2 else 'FINALPAGE', regex=False)[0]
                    assert max(w['bottom'] for w in title_words) < body['top'] - 6
                    assert min(w['top'] for w in title_words) > 0
        print('Passed: opening gap for headings/prose/lists, unchanged later spacing, manual breaks, wrapped running titles and reserved right-aligned dates.')



if __name__ == '__main__':
    main()
