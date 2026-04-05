import type {SidebarsConfig} from '@docusaurus/plugin-content-docs';

const sidebars: SidebarsConfig = {
  tutorialSidebar: [
    'intro',
    {
      type: 'category',
      label: 'Chapters',
      items: [
        'chapters/toolkit',
        'chapters/welcome',
        'chapters/semantics',
        'chapters/navigation',
        'chapters/visual',
        'chapters/forms',
        'chapters/motion',
        'chapters/live-regions',
        'chapters/testing',
        'chapters/polish',
      ],
    },
  ],
};

export default sidebars;
