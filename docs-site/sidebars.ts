import type {SidebarsConfig} from '@docusaurus/plugin-content-docs';

const sidebars: SidebarsConfig = {
  tutorialSidebar: [
    'intro',
    {
      type: 'category',
      label: 'Chapters',
      items: [
        'chapters/toolkit/index',
        'chapters/welcome/index',
        'chapters/semantics',
        'chapters/navigation',
        'chapters/visual',
        'chapters/forms',
        'chapters/motion/index',
        'chapters/live-regions/index',
        'chapters/testing/index',
        'chapters/polish/index',
      ],
    },
  ],
};

export default sidebars;
