#!/usr/bin/env python3
"""Generate template config hover text from the shared defaults documentation.

Run with --check to detect stale generated text. Template-specific notes live
in this file; shared field descriptions live only on defaults in defaults.typ.
"""
from pathlib import Path
import argparse
import re
import sys

ROOT = Path(__file__).resolve().parents[2]
TARGETS = {
    ('report/template.typ', 'report'): ('report', 'Report defaults to figures.placement: auto. Set it to none for source order. The report does not use journal.*, callouts.*, or all table and color fields; pass component settings directly to the component.'),
    ('article/template.typ', 'article'): ('article', 'Article-specific layout settings are in the article group. Settings for disabled contents and lists do not create those lists.'),
    ('book/template.typ', 'book'): ('book', 'Direct style arguments can be overridden by config. book.running-headers overrides the running-headers argument; book also accepts headings.h1-number-size.'),
    ('journal/template.typ', 'journal-entry'): ('journal-entry', 'Journal entries do not create a contents page or figure/table lists. Pass callout settings directly to the callout component.'),
    ('journal/template.typ', 'journal-index'): ('journal-index', 'The index uses page.paper, page.margin, typography.font, typography.size, colors.bg-paper, colors.text-main and colors.brand-primary. Other recognized fields are validated but do not affect its layout.'),
    ('class.typ', 'custom'): ('custom', 'The selected kind controls front matter, heading numbering, links and bibliography behavior.'),
    ('dfg-proposal/dfg.typ', 'dfg-proposal'): ('dfg-proposal', 'The DFG preset also accepts page.header-ascent and decorative.list-indent, list-body-indent, list-spacing and list-block-spacing. Explicit config overrides the form preset.'),
    ('nwo-proposal/template.typ', 'nwo-proposal'): ('nwo-proposal', 'NWO supports page.header-ascent. Profile typography varies with the selected scheme and stage; explicit config overrides profile values.'),
}

def main():
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument('--check', action='store_true')
    args = parser.parse_args()
    defaults = (ROOT / 'defaults.typ').read_text()
    shared = defaults[defaults.index('/// Every key below'):defaults.index('#let defaults = (')]
    reference = (ROOT / 'docs/configuration-reference.md').read_text()
    files = {}
    for (filename, function), (row, note) in TARGETS.items():
        path = ROOT / filename
        text = files.get(path, path.read_text())
        pattern = r'(?m)^/// - config \(dictionary\):.*?(?=^/// - (?:theme|body|header) \(|\Z)'
        position = text.index('#let ' + function + '(')
        doc_start = text.rfind('\n\n', 0, position) + 2
        # Locate the config argument in this function's contiguous doc comment.
        prefix = text[:position]
        matches = list(re.finditer(pattern, prefix, re.S | re.M))
        match = matches[-1]
        row_pattern = r'^\| `journal-entry` / `journal-index` \| (.*?) \|' if row.startswith('journal-') else rf'^\| `{re.escape(row)}`(?: \(experimental\))? \| (.*?) \|'
        found = re.search(row_pattern, reference, re.M)
        if not found:
            raise ValueError(f'Missing template defaults in configuration reference: {row}')
        specific = found.group(1)
        content = ('/// - config (dictionary): partial nested overrides; nested dictionaries merge recursively.\n'
                   + '///   Template defaults: ' + specific + '\n'
                   + '///   ' + note + '\n'
                   + '///   The following values are the shared baseline; template defaults above override them.\n///\n'
                   + shared)
        text = text[:match.start()] + content + text[match.end():]
        files[path] = text
    stale = [p for p, content in files.items() if p.read_text() != content]
    if args.check:
        if stale:
            print('Stale generated config docs: ' + ', '.join(str(p.relative_to(ROOT)) for p in stale), file=sys.stderr)
            return 1
    else:
        for path in stale:
            path.write_text(files[path])
    return 0

if __name__ == '__main__':
    raise SystemExit(main())
