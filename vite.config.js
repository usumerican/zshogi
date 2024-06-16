import { defineConfig } from 'vite';

export default defineConfig((env) => {
  return env.mode == 'lib'
    ? {
        build: {
          lib: {
            entry: 'web/zshogi.js',
            name: 'zshogi',
          },
          copyPublicDir: false,
          outDir: 'dist/lib',
        },
      }
    : {
        base: './',
        build: {
          outDir: 'dist/pages',
        },
      };
});
