import compatModules from "@embroider/virtual/compat-modules";

const seenNames = new Set();

for (const [path, module] of Object.entries(
  import.meta.glob("./**/*.{gjs,js}", { eager: true })
)) {
  const name = path.replace("./", "discourse/").replace(/\.g?js/, "");
  seenNames.add(name);
  window.define(name, [], () => module);
}

for (const [path, module] of Object.entries(
  import.meta.glob("./**/*.hbs", { eager: true })
)) {
  const name = path.replace("./", "discourse/").replace(/\.hbs/, "");
  if (seenNames.has(name)) {
    continue;
  }
  seenNames.add(name);
  window.define(name, [], () => module);
}
