"""Check key-selected CSL publication highlighting, link targets and DFG limits."""
from pathlib import Path
import subprocess
import tempfile

import pdfplumber
from pypdf import PdfReader

ROOT = Path(__file__).resolve().parents[2]


def main():
    with tempfile.TemporaryDirectory(prefix='satz-publications-', dir=ROOT) as directory:
        output = Path(directory)
        bib = '\n'.join(
            '@article{key' + str(i) + ', author={Author' + str(i) + ', Alex}, '
            'title={Title' + str(i) + ' with {Nested Braces}}, journal={Journal' + str(i) + '}, '
            'year={2024}, doi={10.1234/example' + str(i) + '}}' for i in range(11))
        (output / 'refs.bib').write_text(bib)

        def compile_doc(name, source, error=None):
            path = output / (name + '.typ')
            path.write_text(source)
            result = subprocess.run(['typst', 'compile', '--root', str(ROOT), str(path),
                                     str(path.with_suffix('.pdf'))], capture_output=True, text=True)
            if error:
                assert result.returncode and error in result.stderr, result.stderr
                return
            assert result.returncode == 0 and not result.stderr.strip(), result.stderr
            return path.with_suffix('.pdf')

        prefix = '#import "/lib.typ": *\n#show: dfg-proposal.with()\n'
        setup = '#show: proposal-citations.with(read("refs.bib"), highlight: ("key0",))\n'
        source = prefix + setup + '@key0 and @key1\n#dfg-publications()'
        path = compile_doc('selected', source)
        with pdfplumber.open(path) as pdf:
            p = pdf.pages[0]
            text = p.extract_text()
            assert text.count('Title0') == 1 and text.count('Title1') == 1
            words = p.extract_words(extra_attrs=['fontname'])
            for token, bold in [('Title0', True), ('Journal0', True), ('Title1', False), ('Journal1', False)]:
                w = next(w for w in words if w['text'].startswith(token))
                assert ('Bold' in w['fontname']) == bold, w
            assert 'Italic' in next(w for w in words if w['text'].startswith('Journal0'))['fontname']
            # In-text citations stay regular even when their bibliography item is bold.
            cited = next(w for w in words if w['text'].startswith('(Author0'))
            assert 'Bold' not in cited['fontname']
        reader = PdfReader(path)
        links = [a.get_object() for a in reader.pages[0].get('/Annots', [])]
        assert len([a for a in links if '/Dest' in a]) == 2
        assert {a.get('/A', {}).get('/URI') for a in links if '/A' in a} == {'https://doi.org/10.1234/example0', 'https://doi.org/10.1234/example1'}
        for annotation in links:
            if '/Dest' in annotation:
                target = annotation['/Dest']
                assert target[0].indirect_reference.idnum == reader.pages[0].indirect_reference.idnum

        compile_doc('unknown', source.replace('("key0",)', '("missing",)'), error='Unknown highlighted publication key')
        compile_doc('duplicate', source.replace('("key0",)', '("key0", "key0")'), error='Duplicate highlighted')
        keys = ', '.join('"key' + str(i) + '"' for i in range(11))
        cited = '\n'.join('@key' + str(i) for i in range(11))
        too_many = prefix + '#show: proposal-citations.with(read("refs.bib"), highlight: (' + keys + '))\n' + cited + '\n#dfg-publications()'
        compile_doc('too-many', too_many, error='At most 10 highlighted publications')
        compile_doc('ten', too_many.replace(', "key10"', ''))
        compile_doc('missing-setup', prefix + '#dfg-publications()', error='proposal-citations show rule')
        # No CSL initialization means the original native bibliography still works.
        native = compile_doc('native', prefix + '@key0\n#dfg-publications(path("refs.bib"))')
        assert any('/Dest' in a.get_object() for a in PdfReader(native).pages[0].get('/Annots', []))
        example = (ROOT / 'examples/proposal-publications.typ').read_text().replace('"../lib.typ"', '"/lib.typ"').replace('"../dfg-proposal/lit.bib"', '"/dfg-proposal/lit.bib"')
        compile_doc('example', example)
    print('Passed: .bib key selection, complete bold/italic entries, regular unselected entries/citations, DOI and citation destinations, DFG ten-item limit, unknown/duplicate keys and native compatibility.')


if __name__ == '__main__':
    main()
