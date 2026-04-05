import type {ReactNode} from 'react';
import Link from '@docusaurus/Link';
import useDocusaurusContext from '@docusaurus/useDocusaurusContext';
import Layout from '@theme/Layout';
import styles from './index.module.css';

// ── Chapter data ──────────────────────────────────────────────────────────────

const chapters = [
  {
    num: 0,
    title: 'Your Accessibility Toolkit',
    branch: 'chapter-0-toolkit',
    desc: 'Set up VoiceOver, TalkBack, Flutter DevTools, and the accessibility inspector.',
    time: '~15 min',
  },
  {
    num: 1,
    title: 'Welcome to AccessBank',
    branch: 'chapter-1-setup',
    desc: 'Tour the app, explore the semantics tree, and identify what needs fixing.',
    time: '~20 min',
  },
  {
    num: 2,
    title: 'Speaking the Language',
    branch: 'chapter-2-semantics',
    desc: 'Add Semantics widgets, merge and exclude nodes to shape what screen readers announce.',
    time: '~25 min',
  },
  {
    num: 3,
    title: 'Finding Your Way',
    branch: 'chapter-3-navigation',
    desc: 'Fix focus traversal order, keyboard navigation, and eliminate focus traps.',
    time: '~20 min',
  },
  {
    num: 4,
    title: 'See Clearly',
    branch: 'chapter-4-visual',
    desc: 'Meet WCAG contrast requirements, support text scaling, dark mode, and color-blind users.',
    time: '~20 min',
  },
  {
    num: 5,
    title: 'Forms That Work for Everyone',
    branch: 'chapter-5-forms',
    desc: 'Label every input, announce errors, validate accessibly, and wire up autofill.',
    time: '~25 min',
  },
  {
    num: 6,
    title: 'Motion & Interaction',
    branch: 'chapter-6-motion',
    desc: 'Respect Reduce Motion, enlarge touch targets, and add swipe alternatives.',
    time: '~20 min',
  },
  {
    num: 7,
    title: 'Dynamic Content & Live Regions',
    branch: 'chapter-7-live',
    desc: 'Announce loading states, errors, and dynamic updates using live regions.',
    time: '~20 min',
  },
  {
    num: 8,
    title: 'Testing Your Work',
    branch: 'chapter-8-testing',
    desc: 'Write widget tests with semantics matchers and add accessibility checks to CI.',
    time: '~25 min',
  },
  {
    num: 9,
    title: 'The Polished App',
    branch: 'chapter-9-polish',
    desc: 'Full audit, platform-specific tweaks, and celebrate a fully accessible app.',
    time: '~25 min',
  },
];

// ── Feature highlights ────────────────────────────────────────────────────────

const features = [
  {
    icon: '🛠️',
    title: 'Learn by Doing',
    desc: 'Fix a real Flutter banking app — not a toy example. Every chapter makes a broken screen accessible.',
  },
  {
    icon: '📚',
    title: '10 Progressive Chapters',
    desc: 'From installing screen readers in Chapter 0 to a full production audit in Chapter 9.',
  },
  {
    icon: '🔊',
    title: 'Before & After',
    desc: 'Toggle between the inaccessible original and your fix with VoiceOver or TalkBack running. Hear the difference.',
  },
];

// ── Components ────────────────────────────────────────────────────────────────

function HeroSection(): ReactNode {
  return (
    <header className={styles.hero}>
      <div className={styles.heroInner}>
        <p className={styles.heroPre}>Flutter Accessibility Tutorial</p>
        <h1 className={styles.heroTitle}>AccessBank</h1>
        <p className={styles.heroTagline}>
          Fix a real banking app. Learn how screen readers work.<br />
          Ship Flutter code that works for everyone.
        </p>
        <div className={styles.heroButtons}>
          <Link className={styles.btnPrimary} to="/chapters/toolkit">
            Start Chapter 0
          </Link>
          <Link className={styles.btnSecondary} to="/intro">
            Read the Introduction
          </Link>
        </div>
      </div>
    </header>
  );
}

function FeaturesSection(): ReactNode {
  return (
    <section className={styles.features}>
      <div className={styles.container}>
        <div className={styles.featureGrid}>
          {features.map((f) => (
            <div key={f.title} className={styles.featureCard}>
              <div className={styles.featureIcon}>{f.icon}</div>
              <h3 className={styles.featureTitle}>{f.title}</h3>
              <p className={styles.featureDesc}>{f.desc}</p>
            </div>
          ))}
        </div>
      </div>
    </section>
  );
}

function ChapterRoadmap(): ReactNode {
  return (
    <section className={styles.roadmap}>
      <div className={styles.container}>
        <h2 className={styles.sectionTitle}>Chapter Roadmap</h2>
        <p className={styles.sectionSubtitle}>
          Ten focused chapters, each building on the last. Total time: roughly 4 hours.
        </p>
        <ol className={styles.chapterList}>
          {chapters.map((ch) => (
            <li key={ch.num} className={styles.chapterItem}>
              <span className={styles.chapterNum}>{ch.num}</span>
              <div className={styles.chapterBody}>
                <div className={styles.chapterHeader}>
                  <strong className={styles.chapterTitle}>{ch.title}</strong>
                  <span className={styles.chapterTime}>{ch.time}</span>
                </div>
                <p className={styles.chapterDesc}>{ch.desc}</p>
              </div>
            </li>
          ))}
        </ol>
      </div>
    </section>
  );
}

function QuickStartSection(): ReactNode {
  return (
    <section className={styles.quickstart}>
      <div className={styles.container}>
        <h2 className={styles.sectionTitle}>Quick Start</h2>
        <p className={styles.sectionSubtitle}>
          One command sets everything up. Then open two terminals and go.
        </p>
        <div className={styles.quickstartGrid}>
          <div className={styles.codeBlock}>
            <p className={styles.codeLabel}>1. Clone and install</p>
            <pre className={styles.pre}>
              <code>{`git clone <repo-url>
cd accessible
./setup.sh`}</code>
            </pre>
          </div>
          <div className={styles.codeBlock}>
            <p className={styles.codeLabel}>2. Terminal 1 — Tutorial Guide</p>
            <pre className={styles.pre}>
              <code>{`cd docs-site && npm start
# → http://localhost:3000`}</code>
            </pre>
          </div>
          <div className={styles.codeBlock}>
            <p className={styles.codeLabel}>3. Terminal 2 — Banking App</p>
            <pre className={styles.pre}>
              <code>{`flutter run
# → Launches on your device`}</code>
            </pre>
          </div>
        </div>
      </div>
    </section>
  );
}

function PodcastSection(): ReactNode {
  return (
    <section className={styles.podcast}>
      <div className={styles.container}>
        <div className={styles.podcastCard}>
          <div className={styles.podcastText}>
            <h2 className={styles.podcastTitle}>Listen to the Welcome Episode</h2>
            <p className={styles.podcastDesc}>
              Not sure if this tutorial is right for you? Listen to the intro podcast episode where Alex and Sam
              walk through what accessibility means for Flutter developers and what you'll get out of this course.
            </p>
            <p className={styles.podcastNote}>
              Available in the <code>docs/podcast/</code> folder in the repo.
            </p>
          </div>
          <div className={styles.podcastIcon}>🎙️</div>
        </div>
      </div>
    </section>
  );
}

function CtaSection(): ReactNode {
  return (
    <section className={styles.cta}>
      <div className={styles.container}>
        <h2 className={styles.ctaTitle}>Ready to make Flutter accessible?</h2>
        <p className={styles.ctaSubtitle}>
          Start with Chapter 0 — set up your tools, connect a device, and enable VoiceOver or TalkBack.
          The rest follows naturally.
        </p>
        <Link className={styles.btnPrimary} to="/chapters/toolkit">
          Start Chapter 0: Your Accessibility Toolkit
        </Link>
      </div>
    </section>
  );
}

// ── Page ──────────────────────────────────────────────────────────────────────

export default function Home(): ReactNode {
  const {siteConfig} = useDocusaurusContext();
  return (
    <Layout
      title={siteConfig.title}
      description="Learn Flutter accessibility by building a real banking app. 10 progressive chapters, browser-based guide, hot reload on device.">
      <HeroSection />
      <main>
        <FeaturesSection />
        <ChapterRoadmap />
        <QuickStartSection />
        <PodcastSection />
        <CtaSection />
      </main>
    </Layout>
  );
}
