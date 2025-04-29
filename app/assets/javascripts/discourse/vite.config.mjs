import { defineConfig } from "vite";
import { extensions, classicEmberSupport, ember } from "@embroider/vite";
import { babel } from "@rollup/plugin-babel";

export default defineConfig({
  resolve: {
    alias: [
      { find: "pretty-text", replacement: "/../pretty-text/addon" },
      {
        find: "discourse-widget-hbs",
        replacement: "/../discourse-widget-hbs/addon",
      },
      { find: "select-kit", replacement: "/../select-kit/addon" },
      { find: "float-kit", replacement: "/../float-kit/addon" },
      { find: "pretty-text", replacement: "/../pretty-text/addon" },
      // { find: "discourse/tests", replacement: "/tests" },
      { find: "discourse", replacement: "/app" },
      // { find: "admin", replacement: "/../admin/addon" },
      // { find: "@ember-decorators", replacement: "ember-decorators" },
    ],
  },
  plugins: [
    classicEmberSupport(),
    ember(),
    // extra plugins here
    babel({
      babelHelpers: "runtime",
      extensions,
    }),
  ],
});
