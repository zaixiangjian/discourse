export default function customInvokableResolver() {
  return {
    name: "discourse-custom-invokable-resolver",

    resolveId(id) {
      if (id.startsWith("@embroider/virtual/")) {
        console.log(id);
      }
    },
  };
}
