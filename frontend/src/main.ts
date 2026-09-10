import 'crawlab-ui/dist/style.css';
import './brand.css';
import 'vue';
import {createApp} from 'crawlab-ui';

document.documentElement.dataset.brand = 'deeptranx';

void createApp({
  initBaiduTongji: false,
  initUmeng: false,
  initClarity: false,
});
