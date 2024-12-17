"use strict";

const EmberApp = require("ember-cli/lib/broccoli/ember-app");
const { maybeEmbroider } = require("@embroider/test-setup");

module.exports = function (defaults) {
  let app = new EmberApp(defaults, {});

  return maybeEmbroider(app, {
    staticComponents: true,
    staticHelpers: true,
    staticModifiers: true,
    splitAtRoutes: ["wizard"],
    staticAppPaths: ["static"],
  });
};
