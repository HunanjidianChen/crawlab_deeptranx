declare module 'crawlab-ui' {
  interface CreateAppOptions {
    initBaiduTongji?: boolean;
    initUmeng?: boolean;
    initClarity?: boolean;
  }

  export function createApp(options?: CreateAppOptions): Promise<unknown>;
}
