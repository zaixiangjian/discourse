import compatModules from "@embroider/virtual/compat-modules";

const seenNames = new Set();

const moduleSets = [
  compatModules,
  import.meta.glob("./**/*.{gjs,js}", { eager: true }),
  import.meta.glob("./**/*.hbs", { eager: true }),
  import.meta.glob("../../discourse-common/addon/**/*.{gjs,js}", {
    eager: true,
  }),
  import.meta.glob("../../discourse-common/addon/**/*.hbs", {
    eager: true,
  }),
  import.meta.glob("../../float-kit/addon/**/*.{gjs,js}", {
    eager: true,
  }),
  import.meta.glob("../../float-kit/addon/**/*.hbs", {
    eager: true,
  }),
  import.meta.glob("../../select-kit/addon/**/*.{gjs,js}", {
    eager: true,
  }),
  import.meta.glob("../../select-kit/addon/**/*.hbs", {
    eager: true,
  }),
  import.meta.glob("../../dialog-holder/addon/**/*.{gjs,js}", {
    eager: true,
  }),
  import.meta.glob("../../dialog-holder/addon/**/*.hbs", {
    eager: true,
  }),
]
  .map((m) => Object.entries(m))
  .flat();

for (const [path, module] of moduleSets) {
  let name = path
    .replace("../../", "")
    .replace("./", "discourse/")
    .replace("/addon/", "/")
    .replace(/\.\w+$/, "");
  if (!seenNames.has(name)) {
    seenNames.add(name);
    window.define(name, [], () => module);
  }
}
