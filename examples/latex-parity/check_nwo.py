"""Verify every represented NWO profile, all page headers, limits and spacing."""
from pathlib import Path
import json
import subprocess
import tempfile

import pdfplumber
from pypdf import PdfReader

ROOT = Path(__file__).resolve().parents[2]


def main():
    with tempfile.TemporaryDirectory(prefix='satz-nwo-', dir=ROOT) as directory:
        output = Path(directory)
        def compile_doc(name, source, error=None):
            path = output / (name + '.typ')
            path.write_text(source)
            run = subprocess.run(['typst', 'compile', '--root', str(ROOT), str(path), str(path.with_suffix('.pdf'))], text=True, capture_output=True)
            if error:
                assert run.returncode and error in run.stderr, run.stderr
                return
            assert run.returncode == 0 and not run.stderr.strip(), run.stderr
            return path.with_suffix('.pdf')

        count = 0
        for scheme in ['veni', 'vidi', 'vici']:
            for domain in ['science', 'ssh', 'aes', 'zonmw']:
                for stage in ['pre', 'full']:
                    if stage == 'full' and scheme != 'vici': continue
                    if stage == 'pre' and scheme == 'vici' and domain == 'zonmw': continue
                    base = f'#import "/lib.typ": *\n#show: nwo-proposal.with(scheme: "{scheme}", domain: "{domain}", stage: "{stage}")\n'
                    source = base + '= Section\n== Field\n=== Subfield\n==== Detail\nBODYONE \\ BODYTWO\n#pagebreak()\nSecond page\n#pagebreak()\nThird page'
                    path = compile_doc(f'{scheme}-{domain}-{stage}', source)
                    with pdfplumber.open(path) as pdf:
                        assert len(pdf.pages) == 3
                        for index, page in enumerate(pdf.pages):
                            header = page.crop((0, 0, float(page.width), 60)).extract_text()
                            assert f'Page {index+1} / 3' in header and scheme.upper() in header, header
                            assert 'Contents' not in page.extract_text()
                        text = pdf.pages[0].extract_text()
                        assert '1a. Field' in text and '1a1. Subfield' in text and '1a1a.Detail' in ''.join(text.split())
                        words = pdf.pages[0].extract_words(extra_attrs=['fontname', 'size'])
                        one = next(w for w in words if w['text'] == 'BODYONE')
                        two = next(w for w in words if w['text'] == 'BODYTWO')
                        size = 9.5 if stage == 'pre' else 10
                        assert abs(one['size'] - size) < .01 and 'Arial' in one['fontname']
                        assert 1.2 * size <= two['top'] - one['top'] <= 1.25 * size
                        title = pdf.pages[0].search(r'1a1a\. ?Detail', regex=True)[0]
                        assert one['top'] - title['bottom'] >= 2
                        assert abs(one['x0'] - 25 / 25.4 * 72) < 1
                    assert not PdfReader(path).outline
                    count += 1
        assert count == 15

        base = '#import "/lib.typ": *\n#show: nwo-proposal.with()\n'
        text = ' '.join(['word'] * 101)
        field = '#nwo-text("research-idea", ' + json.dumps(text) + ')'
        compile_doc('veni-science-101', base + field)
        compile_doc('veni-ssh-101', base.replace('.with()', '.with(domain: "ssh")') + field, error='0–100 words')
        compile_doc('academic-short', base + '#nwo-text("academic-profile", "short")', error='400–700 words')
        compile_doc('academic-400', base + '#nwo-text("academic-profile", ' + json.dumps(' '.join(['word']*400)) + ')')
        compile_doc('bad-field', base + '#nwo-text("missing", "text")', error='Unknown word-limited field')
        compile_doc('key-outputs-11', base + ('#nwo-key-output(reference: [Example])\n' * 11), error='at most ten key output')
        compile_doc('too-many-indicators', base + '#nwo-key-output(indicators: ([a], [b], [c], [d]))', error='three indicators')
        compile_doc('unavailable-full', base.replace('.with()', '.with(stage: "full")') + 'Body', error='not yet represented')
        compile_doc('unavailable-pre-zonmw', base.replace('.with()', '.with(scheme: "vici", domain: "zonmw")') + 'Body', error='not yet verified')
        compile_doc('bad-year', base.replace('.with()', '.with(year: 2025)') + 'Body', error='2026 profiles')
        compile_doc('bad-scheme', base.replace('.with()', '.with(scheme: "rubicon")') + 'Body', error='veni, vidi or vici')
        compile_doc('fractional-pass', base + '#nwo-page-budget("test", max-pages: 0.5)[#rect(width: 1cm, height: 80mm)]')
        compile_doc('fractional-fail', base + '#nwo-page-budget("test", max-pages: 0.5)[#rect(width: 1cm, height: 140mm)]', error='exceeds 0.5 pages')
        compile_doc('duplicate-budget-key', base + '#nwo-page-budget("test")[A]\n#nwo-page-budget("test")[B]', error='must be unique')
        compile_doc('page-overflow', base + '#nwo-page-budget("test", max-pages: 1)[A\n#pagebreak()\nB\n#pagebreak()\nC]', error='exceeds 1 pages')
        custom = compile_doc('custom-leading', base.replace('.with()', '.with(config: (typography: (leading: 0.65em)))') + 'BODYONE \\ BODYTWO')
        with pdfplumber.open(custom) as pdf:
            words = pdf.pages[0].extract_words()
            a,b = [next(w for w in words if w['text'] == t) for t in ['BODYONE','BODYTWO']]
            assert abs(b['top'] - a['top'] - 9.5 * (1.3663)) < .02

        for name in ['veni', 'vidi', 'vici', 'vici-full']:
            # Included starter files keep relative paths, so compile at their
            # real source location while putting only the PDF in our temp dir.
            run = subprocess.run(['typst', 'compile', '--root', str(ROOT), str(ROOT/'nwo-proposal'/f'{name}.typ'), str(output/f'{name}-starter.pdf')], text=True, capture_output=True)
            assert run.returncode == 0 and not run.stderr.strip(), run.stderr
        for domain in ['science','ssh','aes','zonmw']:
            path = output / f'full-{domain}.pdf'
            run = subprocess.run(['typst', 'compile', '--root', str(ROOT), '--input', f'domain={domain}', str(ROOT/'nwo-proposal/vici-full.typ'), str(path)], text=True, capture_output=True)
            assert run.returncode == 0 and not run.stderr.strip(), run.stderr
            with pdfplumber.open(path) as pdf:
                text = '\n'.join(p.extract_text() for p in pdf.pages)
                assert ('Interest/benefits for stakeholders' in text) == (domain == 'aes')
                assert ('1b. Scientific summary' in text) == (domain != 'zonmw')
                assert ('4 Budget' in text) == (domain != 'zonmw')
        for scheme in ['veni','vidi','vici']:
            for domain in ['science','ssh','aes','zonmw']:
                if scheme == 'vici' and domain == 'zonmw': continue
                path = output / f'pre-{scheme}-{domain}.pdf'
                run = subprocess.run(['typst', 'compile', '--root', str(ROOT), '--input', f'domain={domain}', str(ROOT/'nwo-proposal'/f'{scheme}.typ'), str(path)], text=True, capture_output=True)
                assert run.returncode == 0 and not run.stderr.strip(), run.stderr
                with pdfplumber.open(path) as pdf:
                    text = '\n'.join(p.extract_text() for p in pdf.pages)
                    assert '4a. Personal details' in text
                    assert 'Key output 1' in text
                    assert ('Word count: 59' in text) == (scheme != 'veni' or domain != 'zonmw')
        forbidden = '#import "/lib.typ": *\n#show: nwo-proposal.with(scheme: "vici", stage: "full")\n#show: proposal-citations.with(read("/dfg-proposal/lit.bib"), highlight: ("duncan2010",))\n@duncan2010\n#proposal-publications()'
        compile_doc('nwo-no-highlight', forbidden, error='prohibit highlighting')
    print('Passed: all 15 represented NWO profiles, continuous headers, numbering, font/leading/margins, bookmarks, domain-specific starters, text/key-output/page limits, unsupported forms and prohibited publication highlighting.')


if __name__ == '__main__':
    main()
