"""Verify proposal headers on every page, DFG limits, hierarchy and exact budgets.

Run with Python containing pdfplumber; uses temporary output, no committed PDFs.
"""
from pathlib import Path
import subprocess
import tempfile

import pdfplumber

ROOT = Path(__file__).resolve().parents[2]


def main():
    with tempfile.TemporaryDirectory(prefix="satz-proposals-", dir=ROOT) as directory:
        output = Path(directory)

        def compile_doc(name, source, error=None):
            path = output / (name + '.typ')
            path.write_text(source)
            result = subprocess.run(['typst', 'compile', '--root', str(ROOT), str(path),
                                     str(path.with_suffix('.pdf'))], capture_output=True, text=True)
            if error:
                assert result.returncode != 0 and error in result.stderr, result.stderr
                return
            assert result.returncode == 0, result.stderr
            assert not result.stderr.strip(), result.stderr
            return pdfplumber.open(path.with_suffix('.pdf'))

        def load(relative):
            return (ROOT / relative).read_text().replace('"../lib.typ"', '"/lib.typ"').replace('"lit.bib"', '"/dfg-proposal/lit.bib"')

        for name, lang in [('example.typ', 'english'), ('example-de.typ', 'german')]:
            with compile_doc(lang, load('dfg-proposal/' + name)) as pdf:
                assert len(pdf.pages) == 3
                for index, page in enumerate(pdf.pages):
                    header = page.crop((0, 0, float(page.width), 60)).extract_text()
                    n, limit = (1, 17) if index == 0 else (index, 8)
                    expected = f'page {n} of max. {limit}' if lang == 'english' else f'Seite {n} von max. {limit}'
                    assert expected in header, header
                    assert '53.01 – 09/26' in header, header
                    chars = page.crop((0, 60, float(page.width), float(page.height))).chars
                    assert all('Arial' in ch['fontname'] for ch in chars if ch['text'].strip())
                    assert all(ch['size'] >= 10.99 for ch in chars if ch['text'].strip())
                    assert abs(float(page.width) - 595.276) < 1
                    assert abs(min(ch['x0'] for ch in chars if ch['text'].strip()) - 25 / 25.4 * 72) < 1
                    assert max(ch['x1'] for ch in chars) <= float(page.width) - 20 / 25.4 * 72 + 1
                text = '\n'.join(page.extract_text() for page in pdf.pages)
                assert '4.1.4.1' in text and '5.1.3.2' in text and '5.8' in text
                assert ('62700.00 €' if lang == 'english' else '62700,00 €') in text
                # Right page mark stays at the right margin; it is not a footer.
                for page in pdf.pages:
                    words = page.crop((0, 0, float(page.width), 60)).extract_words()
                    assert abs(words[-1]['x1'] - (float(page.width) - 20 / 25.4 * 72)) < 1
                    assert not page.crop((0, float(page.height)-30, float(page.width), float(page.height))).extract_text()

        base = '#import "/lib.typ": *\n#show: dfg-proposal.with()\n'
        def pages(count):
            return '\n#pagebreak()\n'.join(f'Page marker {i}' for i in range(count))
        source = base + pages(17) + '\n#dfg-supplement()\n' + pages(8)
        with compile_doc('full-limits', source) as pdf:
            assert len(pdf.pages) == 25
            for index, page in enumerate(pdf.pages):
                expected = f'page {index+1} of max. 17' if index < 17 else f'page {index-16} of max. 8'
                assert expected in page.crop((0, 0, float(page.width), 60)).extract_text()
        compile_doc('too-long-first', base + pages(18), error='sections 1–3 exceed 17 pages')
        compile_doc('too-long-second', base + 'First part\n#dfg-supplement()\n' + pages(9), error='sections 4–5 exceed 8 pages')
        compile_doc('duplicate-split', base + 'A\n#dfg-supplement()\nB\n#dfg-supplement()\nC', error='only once')
        compile_doc('invalid-lang', base.replace('.with()', '.with(language: "dutch")') + 'Body', error='english or german')
        with compile_doc('draft', base.replace(".with()", ".with(check-pages: false)") + pages(17) + "\n#dfg-supplement()\n" + pages(9)) as pdf:
            assert len(pdf.pages) == 26
        compile_doc('missing-split', base + '= One\nText\n= Two\nText\n= Three\nText\n= Four\nText', error='immediately before section 4')
        with compile_doc('leading-and-counter', base + r'LINEONE \ LINETWO' + '\n#dfg-supplement()\n#context[Body page #counter(page).display()]') as pdf:
            words = pdf.pages[0].extract_words()
            one = next(w for w in words if w['text'] == 'LINEONE')
            two = next(w for w in words if w['text'] == 'LINETWO')
            assert two['top'] - one['top'] >= 11 * 1.2
            assert 'Body page 1' in pdf.pages[1].extract_text()
        # Legacy API and the existing consuming document still compile.
        with compile_doc('legacy', load('dfg-proposal/main.typ').replace('"@preview/satz:0.1.1"', '"/lib.typ"')) as pdf:
            assert len(pdf.pages) > 0
        with compile_doc('publications', base + '= Publications\n@duncan2010\n#dfg-publications("/dfg-proposal/lit.bib")') as pdf:
            sizes = {round(ch['size'], 1) for p in pdf.pages for ch in p.chars}
            assert 9.0 in sizes
            assert 'Duncan' in pdf.pages[0].extract_text()
        compile_doc('small-publications', base + '#dfg-publications("/dfg-proposal/lit.bib", size: 8pt)', error='at least 9pt')
        with compile_doc('general', load('proposal/example.typ')) as pdf:
            assert len(pdf.pages) == 2
            for index, page in enumerate(pdf.pages):
                assert f'Page {index+1} / 2' in page.crop((0, 0, float(page.width), 60)).extract_text()
            assert '63250.00 €' in pdf.pages[-1].extract_text()
        with compile_doc('general-de', '#import "/lib.typ": project-proposal\n#show: project-proposal.with(title: [Projekt], language: "german")\n= Ziele\nText') as pdf:
            assert 'Seite 1 / 1' in pdf.pages[0].extract_text()
        budget = '#import "/lib.typ": proposal-budget\n#proposal-budget(((description: [A], unit-cost: 10, quantity: 3), (description: [B], unit-cost: 1)))'
        with compile_doc('cents', budget) as pdf:
            assert '0.31 €' in pdf.pages[0].extract_text()
        compile_doc('invalid-money', budget.replace('unit-cost: 10', 'unit-cost: 0.1'), error='integer cents')
        compile_doc('invalid-quantity', budget.replace('quantity: 3', 'quantity: 0'), error='positive integer')
    print('Passed: bilingual DFG starters, all-page headers and reset, 17+8 limits, draft mode, hierarchy, Arial, margins, bibliography, legacy consumer, general proposals and budget arithmetic.')


if __name__ == '__main__':
    main()
