import {themes as prismThemes} from 'prism-react-renderer';
import type {Config} from '@docusaurus/types';
import type * as Preset from '@docusaurus/preset-classic';

// This runs in Node.js - Don't use client-side code here (browser APIs, JSX...)

const config: Config = {
  title: 'AccessBank Tutorial',
  tagline: 'Learn Flutter accessibility by building a real banking app',
  favicon: 'img/favicon.ico',

  future: {
    v4: true,
  },

  url: 'https://accessbank-tutorial.dev',
  baseUrl: '/',

  organizationName: 'accessbank',
  projectName: 'accessbank-tutorial',

  onBrokenLinks: 'throw',

  themes: ['@docusaurus/theme-mermaid'],
  markdown: {
    mermaid: true,
  },

  i18n: {
    defaultLocale: 'en',
    locales: ['en'],
  },

  presets: [
    [
      'classic',
      {
        docs: {
          sidebarPath: './sidebars.ts',
          routeBasePath: '/',
        },
        blog: false,
        theme: {
          customCss: './src/css/custom.css',
        },
      } satisfies Preset.Options,
    ],
  ],

  themeConfig: {
    image: 'img/docusaurus-social-card.jpg',
    colorMode: {
      respectPrefersColorScheme: true,
    },
    navbar: {
      title: 'AccessBank Tutorial',
      logo: {
        alt: 'AccessBank Logo',
        src: 'img/logo.svg',
      },
      items: [
        {
          type: 'docSidebar',
          sidebarId: 'tutorialSidebar',
          position: 'left',
          label: 'Tutorial',
        },
        {
          to: '/chapters/toolkit',
          label: 'Get Started',
          position: 'right',
        },
      ],
      style: 'dark',
    },
    footer: {
      style: 'dark',
      links: [
        {
          title: 'Tutorial',
          items: [
            {
              label: 'Introduction',
              to: '/intro',
            },
            {
              label: 'Chapter 0: Toolkit',
              to: '/chapters/toolkit',
            },
          ],
        },
      ],
      copyright: `Copyright © ${new Date().getFullYear()} AccessBank Tutorial. Built with Docusaurus.`,
    },
    prism: {
      theme: prismThemes.github,
      darkTheme: prismThemes.dracula,
      additionalLanguages: ['dart', 'bash', 'yaml', 'json'],
    },
  } satisfies Preset.ThemeConfig,
};

export default config;
