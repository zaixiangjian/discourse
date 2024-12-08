import { defineConfig } from "vite";
import {
  resolver,
  hbs,
  scripts,
  templateTag,
  optimizeDeps,
  compatPrebuild,
  assets,
  contentFor,
} from "@embroider/vite";
import { babel } from "@rollup/plugin-babel";
import viteProxy from "./vite-proxy";

const extensions = [
  ".mjs",
  ".gjs",
  ".js",
  ".mts",
  ".gts",
  ".ts",
  ".hbs",
  ".json",
];
export default defineConfig(({ mode }) => {
  return {
    resolve: {
      extensions,
      alias: [
        { find: "discourse-common", replacement: "/../discourse-common/addon" },
        { find: "pretty-text", replacement: "/../pretty-text/addon" },
        {
          find: "discourse-widget-hbs",
          replacement: "/../discourse-widget-hbs/addon",
        },
        { find: "select-kit", replacement: "/../select-kit/addon" },
        { find: "float-kit", replacement: "/../float-kit/addon" },
        { find: "discourse", replacement: "/app" },
        // { find: "@ember-decorators", replacement: "ember-decorators" },
      ],
    },
    plugins: [
      hbs(),
      templateTag(),
      scripts(),
      resolver(),
      compatPrebuild(),
      assets(),
      contentFor(),
      viteProxy(),

      babel({
        babelHelpers: "runtime",
        extensions,
      }),
    ],
    optimizeDeps: {
      ...optimizeDeps(),
      include: ["virtual-dom"],
    },
    server: {
      port: 4200,
    },
    build: {
      manifest: true,
      outDir: "dist",
      rollupOptions: {
        input: {
          main: "index.html",
          ...(shouldBuildTests(mode)
            ? { tests: "tests/index.html" }
            : undefined),
        },
        output: {
          manualChunks(id, { getModuleInfo }) {
            if (id.includes("node_modules")) {
              return "vendor";
            }
          },
        },
      },
    },
  };
});

function shouldBuildTests(mode) {
  return mode !== "production" || process.env.FORCE_BUILD_TESTS;
}
