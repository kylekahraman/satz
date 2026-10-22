# Documentation maintenance

Public site: https://kylekahraman.github.io/satz/

The site uses Astro Starlight. With Node.js 24 installed, run:

```sh
npm ci
npm run build
python3 tools/docs/check.py
```

The check compiles complete published-package examples and checks internal page
links, anchors, document language, and top-level headings. It requires the Typst
CLI. This is maintainer tooling; readers need neither Python nor Node.js.

If your machine overrides `@preview/satz:0.1.1` with a development symlink,
extract the official package archive from
https://packages.typst.org/preview/satz-0.1.1.tar.gz into a temporary
`preview/satz/0.1.1` directory. Pass its package root to
`python3 tools/docs/check.py --package-path /path/to/packages` to test the
published release rather than your override.

The GitHub Actions workflow builds pull requests and deploys main-branch pushes
or manual runs to GitHub Pages. The repository's Pages setting must use GitHub
Actions. Do not commit the generated `site/` directory or compiled PDFs.

Keep beginner examples on the published API. Label development-only features,
keep multi-file setup optional, and use descriptive links and ordered setup
steps. Review navigation and search in the browser after structural changes.
