import { defineCollection } from 'astro:content';
import { glob } from 'astro/loaders';
import { docsSchema } from '@astrojs/starlight/schema';

// Keep the existing Markdown paths so repository links remain valid.
export const collections = {
  docs: defineCollection({
    loader: glob({ pattern: '**/*.md', base: './docs/site' }),
    schema: docsSchema(),
  }),
};
