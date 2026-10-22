import { defineConfig } from 'astro/config';
import starlight from '@astrojs/starlight';

export default defineConfig({
  site: 'https://kylekahraman.github.io',
  base: '/satz',
  outDir: './site',
  trailingSlash: 'always',
  integrations: [starlight({
    title: 'satz',
    description: 'Start writing with Satz: Typst templates for reports, journals, letters, and proposals.',
    social: [{ icon: 'github', label: 'GitHub', href: 'https://github.com/kylekahraman/satz' }],
    sidebar: [
      { label: 'Start here', link: '/' },
      { label: 'Get started', items: [
        { slug: 'getting-started/setup' },
        { slug: 'getting-started/report' },
        { slug: 'getting-started/letter' },
      ] },
      { label: 'Guides', items: [
        { slug: 'guides/journals' },
        { slug: 'guides/figures-and-tables' },
        { slug: 'guides/proposals' },
        { slug: 'guides/layouts' },
        { slug: 'guides/troubleshooting' },
        { slug: 'guides/development' },
      ] },
      { label: 'Reference', items: [
        { slug: 'reference/templates' },
        { slug: 'reference/configuration' },
      ] },
      { label: 'Contributing', slug: 'maintainers/api-design' },
    ],
  })],
});
