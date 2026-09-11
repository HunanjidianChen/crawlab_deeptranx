declare module 'crawlab-ui' {
  interface CreateAppOptions {
    initBaiduTongji?: boolean;
    initUmeng?: boolean;
    initClarity?: boolean;
    rootRoutes?: import('vue-router').RouteRecordRaw[];
  }

  export function createApp(options?: CreateAppOptions): Promise<unknown>;
}
