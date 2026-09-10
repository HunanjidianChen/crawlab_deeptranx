import {resolve} from 'node:path';
import {defineConfig, loadEnv} from 'vite';
import vue from '@vitejs/plugin-vue';
import dynamicImport from 'vite-plugin-dynamic-import';

export default defineConfig(({mode}) => {
  const env = loadEnv(mode, process.cwd(), '');
  const apiBase = env.VITE_API_BASE_URL || '/api';
  const proxyTarget = env.VITE_API_PROXY_TARGET || 'http://crawlab:8080';

  return {
    resolve: {
      dedupe: ['vue', 'element-plus', 'codemirror'],
      alias: [{find: '@', replacement: resolve(__dirname, 'src')}],
    },
    plugins: [vue(), dynamicImport()],
    server: {
      host: '0.0.0.0',
      port: 5173,
      strictPort: true,
      proxy: {
        [apiBase]: {
          target: proxyTarget,
          changeOrigin: true,
        },
      },
    },
  };
});
