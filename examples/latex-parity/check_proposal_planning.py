"""Verify Gantt geometry, cross-references, counters, localization and guards."""
from pathlib import Path
import subprocess
import tempfile
import pdfplumber
from pypdf import PdfReader

ROOT = Path(__file__).resolve().parents[2]
MM = 72 / 25.4


def main():
    with tempfile.TemporaryDirectory(prefix='satz-planning-', dir=ROOT) as directory:
        output = Path(directory)
        def compile_doc(name, source, error=None):
            path = output / (name + '.typ')
            path.write_text(source)
            result = subprocess.run(['typst', 'compile', '--root', str(ROOT), str(path), str(path.with_suffix('.pdf'))], capture_output=True, text=True)
            if error:
                assert result.returncode and error in result.stderr, result.stderr
                return
            assert result.returncode == 0 and not result.stderr.strip(), result.stderr
            return path.with_suffix('.pdf')
        source = (ROOT / 'examples/proposal-planning.typ').read_text().replace('"../lib.typ"', '"/lib.typ"')
        path = compile_doc('public', source)
        with pdfplumber.open(path) as pdf:
            assert len(pdf.pages) == 2
            assert 'WP 1 – Reference protocol' in pdf.pages[0].extract_text()
            assert 'WP 2 – Independent validation' in pdf.pages[0].extract_text()
            assert 'links WP 1 and WP 2' in pdf.pages[1].extract_text()
            for i, page in enumerate(pdf.pages): assert f'Page {i+1} / 2' in page.extract_text()
            chart = pdf.pages[1]
            origin = 25 * MM + 40 * MM + 2 * 10 * MM
            cell = (chart.width - 50 * MM - 40 * MM - 2 * 10 * MM) / 24
            bars = [r for r in chart.rects if r.get('fill') and abs(r['height'] - 6) < .01 and r['width'] > 10]
            assert len(bars) == 5
            for bar, (start, end) in zip(bars, [(1, 3), (3, 9), (10, 15), (17, 20), (21, 24)]):
                assert abs(bar['x0'] - (origin + (start - 1) * cell + .5)) < .02
                assert abs(bar['width'] - ((end - start + 1) * cell - 1)) < .02
            groups = [r for r in chart.rects if r.get('fill') and abs(r['height'] - 3) < .01 and r['width'] > 10]
            assert len(groups) == 2
            for bar, (start, end) in zip(groups, [(1, 9), (10, 24)]):
                assert abs(bar['x0'] - (origin + (start - 1) * cell + .5)) < .02
                assert abs(bar['width'] - ((end - start + 1) * cell - 1)) < .02
            assert len(chart.curves) == 2
            for diamond, period in zip(chart.curves, [9, 20]):
                assert abs((diamond['x0'] + diamond['x1']) / 2 - (origin + (period - .5) * cell)) < .02
            assert '63250.00 €' in chart.extract_text()
        assert len(PdfReader(path).pages[1].get('/Annots', [])) >= 4
        base = '#import "/lib.typ": *\n#set page(paper: "a4", margin: 25mm)\n'
        chart = '#proposal-gantt(((label: [TASK], spans: ((2, 4), (7, 8))),), periods: 8, unit: "quarter", start-year: 2027, language: "german")'
        with pdfplumber.open(compile_doc('quarters', base + chart)) as pdf:
            text = pdf.pages[0].extract_text()
            assert '2027' in text and '2028' in text and 'Q4' in text and 'Arbeitspaket' in text
        # The helpers work in the DFG form at its default 11pt chart size.
        dfg = '#import "/lib.typ": *\n#show: dfg-proposal.with()\n= Plan\n#proposal-gantt(((label: [TASK], spans: ((1, 24),)),))'
        with pdfplumber.open(compile_doc('dfg', dfg)) as pdf:
            assert 'page 1 of max. 17' in pdf.pages[0].extract_text()
            task = pdf.pages[0].search('TASK', regex=False)[0]['chars'][0]
            assert abs(task['size'] - 11) < .01
        wp = '#work-package(title: [Ziel], objective: [OBJ], language: "german") <wp>\nVerweis: @wp.\n= Heading'
        with pdfplumber.open(compile_doc('work-package', base + wp)) as pdf:
            text = pdf.pages[0].extract_text()
            assert 'AP 1' in text and 'Ziel: OBJ' in text
        for periods in [1, 14, 36]:
            compile_doc(f'partial-{periods}', base + f'#proposal-gantt(((label: [TASK], spans: ((1, {periods}),)),), periods: {periods}, size: 9pt)')
        long = '#import "/lib.typ": document-class, work-package\n#show: document-class.with(kind: "proposal", config: (toc: (depth: 0), page: (paper: "a6", margin: 12mm)))\n#work-package(title: [Long summary], objective: [Objective], body: lorem(500)) <wp>\nReference @wp.'
        with pdfplumber.open(compile_doc('long-summary', long)) as pdf:
            assert len(pdf.pages) > 2
            for page in pdf.pages:
                assert max(c['bottom'] for c in page.chars) < page.height - 12 * MM + 1
        for name, bad, error in [

            ('periods', chart.replace('periods: 8', 'periods: 0'), 'positive integer'),
            ('bounds', chart.replace('(2, 4)', '(0, 4)'), 'outside the chart'),
            ('overlap', chart.replace('(7, 8)', '(3, 8)'), 'must not overlap'),
            ('resources', chart.replace('label: [TASK]', 'label: [TASK], resources: ([1],)'), 'resource values'),
            ('kind', chart.replace('label: [TASK]', 'label: [TASK], kind: "unknown"'), 'Unknown Gantt'),
            ('width', chart.replace('periods: 8', 'periods: 120'), 'too narrow'),
        ]:
            compile_doc(name, base + bad, error=error)
        print('Passed: task/group geometry, split phases, milestone centers, WP references/counters, headers, quarters/years, localization, DFG size and invalid input guards.')


if __name__ == '__main__':
    main()
