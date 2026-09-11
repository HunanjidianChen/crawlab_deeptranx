import 'crawlab-ui/dist/style.css';
import './brand.css';
import 'vue';
import {createApp} from 'crawlab-ui';
import type {RouteRecordRaw} from 'vue-router';
import UserManual from './views/UserManual.vue';

const brandName = 'DEEPTRANX';
const pageTitle = `${brandName}|采集管理系统`;
const rootRoutes: RouteRecordRaw[] = [
  {
    name: 'UserManual',
    path: 'misc/user-manual',
    component: UserManual,
    meta: {
      title: '操作使用手册',
    },
  },
];

document.documentElement.dataset.brand = brandName;
document.title = pageTitle;

const titleElement = document.querySelector('title');
if (titleElement) {
  new MutationObserver(() => {
    if (document.title !== pageTitle) {
      document.title = pageTitle;
    }
  }).observe(titleElement, {
    childList: true,
    characterData: true,
    subtree: true,
  });
}

void createApp({
  initBaiduTongji: false,
  initUmeng: false,
  initClarity: false,
  rootRoutes,
});
