const chokidar = require("chokidar");
const http = require("http");
const fs = require("fs");
const WebSocketServer = require("websocket").server;
const {exec} = require("child_process");
const tcpPortUsed = require("tcp-port-used");
const chalk = require("chalk");
const log = console.log;

tcpPortUsed.check(4077, "127.0.0.1").then(inuse => {
  if (inuse) {
    log(chalk.yellow("\n┌──────────────────────────────────────┐"));
    log(chalk.yellow("│                                      │"));
    log(chalk.yellow("│   ") +
      chalk.red("The devServer is already running") +
      chalk.yellow("   │"));
    log(chalk.yellow("│        ") +
      chalk.cyan("Point your browser to") +
      chalk.yellow("         │"));
    log(chalk.yellow("│        ") +
      chalk.cyan("http://localhost:4077") +
      chalk.yellow("         │"));
    log(chalk.yellow("│                                      │"));
    log(chalk.yellow("└──────────────────────────────────────┘"));
    process.exit();
  }
  run();
}, err => {
  console.log("Error in checking port:", err.message);
});

function createWatcher(path) {
  return chokidar.watch(path, {
    ignored: /^node_modules/,
  });
}

function detectedChange(path, type, isRebuilding = true) {
  console.log("\x1b[36m%s\x1b[0m", `\nCHANGE DETECTED in ${path}`);
  if (isRebuilding) {
    console.log("\x1b[33m%s\x1b[0m", `     rebuilding ${type}`);
  }
}

const devServer = {
  connections: [],
  hostname: "localhost",
  port: 4077,
  cssWatcher: createWatcher("./src/css/*.scss"),
  jsWatcher: createWatcher("./src/**/*.js"),
  htmlWatcher: createWatcher("./**/*.html"),
  splashImage: undefined,
  sendFile: (res, contentType, file) => {
    res.writeHeader(200, {
      "Content-Type": contentType,
    });
    res.write(file);
    res.end();
  },

  loadFile: (path, instance, send = true) => {
    fs.readFile(path, {}, (err, file) => {
      devServer[instance] = file;
      send && devServer.sendUpdateCommand();
    });
  },

  sendUpdateCommand: () => {
    console.log("\x1b[33m%s\x1b[0m", "     sending update command\n");
    devServer.connections.forEach(con => {
      con.sendUTF("update");
    });
  },

  js: undefined,
  compileJS: (send = true) => {
    exec("npx babel src --out-file lib/index.js", {}, () => {
      devServer.loadFile("./lib/index.js", "js", send);
    });
  },

  css: undefined,
  compileCSS: (send = true) => {
    exec("sass src/css/index.scss:lib/style.css", {}, () => {
      devServer.loadFile("./lib/style.css", "css", send);
    });
  },

  html: undefined,
};

devServer.compileJS(false);
devServer.compileCSS(false);
devServer.loadFile("./index.html", "html", false);
devServer.loadFile("./public/background.jpg", "splashImage", false);

devServer.cssWatcher.on("change", (path, evt) => {
  detectedChange(path, "CSS");
  devServer.compileCSS();
});

devServer.htmlWatcher.on("change", path => {
  detectedChange(path, "HTML", false);
  devServer.loadFile("./index.html", "html");
});

devServer.jsWatcher.on("change", path => {
  detectedChange(path, "JavaScript");
  devServer.compileJS();
});

const server = http.createServer((req, res) => {
  switch (req.url) {
    case "/lib/index.js":
      devServer.sendFile(res, "text/javascript", devServer.js);
      break;

    case "/lib/style.css":
      devServer.sendFile(res, "text/css", devServer.css);
      break;

    case "/background.jpg":
      devServer.sendFile(res, "image/webp", devServer.splashImage);
      break;

    case "/":
      devServer.sendFile(res, "text/html", devServer.html);
      break;

    default:
      res.writeHeader(204);
      res.end();
      break;
  }
});

const wsServer = new WebSocketServer({httpServer: server});

wsServer.on("request", request => {
  if (new RegExp(`/${devServer.hostname}:${devServer.port}`).test(request.origin)) {
    const connection = request.accept(null, request.origin);
    devServer.connections.push(connection);

    console.log(
        new Date() + ": Connection from origin " + request.origin + " accepted"
    );
  }
});

wsServer.on("close", connection => {
  const index = devServer.connections.indexOf(connection);
  devServer.connections.splice(index, 1);
});

function run() {
  server.listen(devServer.port, devServer.hostname, () => {
    console.log(`Server running on http://${devServer.hostname}:${devServer.port}\n`);
  });
}
