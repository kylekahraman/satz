import { defineConfig } from 'astro/config';
import starlight from '@astrojs/starlight';

export default defineConfig({
  site: 'https://kylekahraman.github.io',
  base: '/satz',
  outDir: './site',
  trailingSlash: 'always',
  integrations: [starlight({
    title: 'satz',
    customCss: ['./src/styles/custom.css'],
    description: 'Start writing with Satz: Typst templates for reports, journals, letters, and proposals.',
    social: [{ icon: 'github', label: 'GitHub', href: 'https://github.com/kylekahraman/satz' }],
    sidebar: [
      { label: 'Start here', link: '/' },
      { label: 'Set up the local 0.2.0 package', link: '/getting-started/setup/' },
      { label: 'Tutorials — follow this order', items: [
        { slug: 'getting-started/letter' },
        { slug: 'getting-started/report' },
        { slug: 'guides/journals' },
        { slug: 'getting-started/thesis-book' },
        { slug: 'getting-started/invoice' },
        { slug: 'getting-started/article' },
        { slug: 'guides/proposals' },
        { slug: 'getting-started/cover-page' },
        { slug: 'getting-started/legal-complaint' },
        { slug: 'getting-started/guest-contract' },
        { slug: 'getting-started/complete-document' },
      ] },
      { label: 'Guides', items: [
        { slug: 'guides/figures-and-tables' },
        { slug: 'guides/layouts' },
        { slug: 'guides/troubleshooting' },
        { slug: 'guides/development' },
      ] },
      { label: 'Reference', items: [
        { slug: 'reference/templates' },
        { slug: 'reference/api' },
        { slug: 'reference/configuration' },
      ] },
      { label: 'Contributing', items: [
        { slug: 'maintainers/architecture' },
        { slug: 'maintainers/contributing' },
        { slug: 'maintainers/api-design' },
      ] },
    ],
  })],
});
