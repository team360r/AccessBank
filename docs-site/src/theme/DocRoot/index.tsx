import React from 'react';
import DocRoot from '@theme-original/DocRoot';
import type DocRootType from '@theme/DocRoot';
import type {WrapperProps} from '@docusaurus/types';
import {useLocation} from '@docusaurus/router';
import {useProgress} from '../../hooks/useProgress';

type Props = WrapperProps<typeof DocRootType>;

export default function DocRootWrapper(props: Props): React.ReactElement {
  const {pathname} = useLocation();
  const {markVisited} = useProgress();

  React.useEffect(() => {
    markVisited(pathname);
  }, [pathname, markVisited]);

  return <DocRoot {...props} />;
}
