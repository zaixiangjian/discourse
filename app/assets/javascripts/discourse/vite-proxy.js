import fetch from "node-fetch";

const middleware = async (req, res, next) => {
  // console.log(req);
  const viteServedPatterns = [".js", ".gjs", "@vite", "@fs", ".hbs"];
  if (req.url.startsWith("/@vite/")) {
    return next();
  }

  req.headers["X-Discourse-Ember-CLI"] = "true";
  const passthroughHeaders = {
    "X-Discourse-Ember-CLI": "true",
  };
  for (const [key, value] of Object.entries(req.headers)) {
    if (key.startsWith(":")) {
      continue;
    }
    passthroughHeaders[key] = value;
  }

  try {
    const response = await fetch(`http://localhost:3000/${req.url}`, {
      method: req.method,
      body: /GET|HEAD/.test(req.method) ? null : req.body,
      headers: passthroughHeaders,
      redirect: "manual",
    });

    response.headers.forEach((value, header) => {
      if (header === "set-cookie") {
        // Special handling to get array of multiple Set-Cookie header values
        // per https://github.com/node-fetch/node-fetch/issues/251#issuecomment-428143940
        res.setHeader("set-cookie", response.headers.raw()["set-cookie"]);
      } else {
        res.setHeader(header, value);
      }
    });
    // res.setHeader("content-encoding", null);

    res.statusCode = response.status;
    res.end(Buffer.from(await response.arrayBuffer()));
  } catch (e) {
    console.error(e);
    res.end(`
      <html>
        <h1>Discourse Proxy Error</h1>
        <pre><code>${e.stack}</code></pre>
      </html>
    `);
  }

  // res.end(`
  //   <html>
  //     <h1>Discourse Ember CLI Proxy Error</h1>
  //     <pre><code>Bad tings</code></pre>
  //   </html>
  // `);
  // custom handle request...
};

export default () => ({
  name: "configure-server",
  configureServer(server) {
    server.middlewares.use(middleware);
  },
  configurePreviewServer(server) {
    server.middlewares.use(middleware);
  },
});
