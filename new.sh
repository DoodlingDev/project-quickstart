#!/bin/sh
# thanks to thoughtbot laptop script
fancy_echo() {
  local fmt="$1"; shift
  printf "\n$fmt\n" "$0"
}

if [ ! $1 ]; then
  fancy_echo "Please supply a project name"
  exit
fi

fancy_echo "Creating folder structure"
mkdir $1
cd $1
mkdir -pv src/css
mkdir lib

fancy_echo "Creating package.json"
cat << EOF > ./package.json
{
  "name": "$1",
  "description": "Aji codes for fun: $1",
  "version": "1.0.0",
  "main": "index.js",
  "scripts": {
    "test": "mocha ./**/*.test.js",
    "start": "node devServer.js",
    "build": "babel src -d lib"
  },
  "author": "The Stabby Lambdas",
  "license": "MIT"
}
EOF

fancy_echo "Creating index.html"
cat << EOF > ./index.html
<!DOCTYPE html>
<html>
  <head>
    <meta charset="UTF-8" />
    <meta name="viewport" content="width=device-width" />
    <script>
      const Game = {};
      Game.setup = undefined;
      Game.loop = undefined;
    </script>
    <style>
      #code-for-fun {
        position: relative;
        display: grid;
        grid-template-columns: [left-gutter] 35% [content] 50% [right-gutter] 15%;
        grid-template-rows: [top-margin] 150px [content-top] 50px [content] auto;
      }
      #code-for-fun .code-for-fun-splash-container {
        display: grid;
        grid-template-columns: [left] 70% [right] 30%;
        font-family: sans-serif;
        box-sizing: border-box;
        color: white;
        background-color: #1282A2;
        grid-column-start: content;
        grid-row-start: content-top;
        grid-row-end: content;
        min-height: 150px;
        border-radius: 4px;
        padding: 1rem;
        box-shadow: 0px 6px 46px 0px rgba(0,0,0,0.39);
        z-index: 1;
      }
      #code-for-fun .code-for-fun-splash-textbox {
        grid-column-start: right;
        align-self: end;
      }
      #code-for-fun .code-for-fun-splash-background {
        width: 100%;
        height: 200px;
        overflow: hidden;
        position: relative;
        grid-column-start: left-gutter;
        grid-column-end: right;
        background-color: #282828;
      }
      #code-for-fun .code-for-fun-bg-block {
        transition: background-color 1s;
        position: absolute;
      }
    </style>
    <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/normalize/8.0.1/normalize.min.css" type="text/css" media="screen" title="no title" charset="utf-8">
    <link rel="stylesheet" href="./lib/style.css" type="text/css" media="screen" title="no title" charset="utf-8">
    <title></title>
  </head>
  <body>
    <div id="code-for-fun"></div>
    <script src="./lib/index.js"></script>
    <script charset="utf-8">

      window.WebSocket = window.WebSocket || window.MozWebSocket;

      const connection = new WebSocket('ws://127.0.0.1:4077');
      connection.onopen = () => { console.log("open connection") };
      connection.onerror = (err) => { console.log("err!", err) };
      connection.onmessage = message => {
        if (message.data === "update") {
          window.location.href = "http://localhost:4077";
        }
      }

      Game.setup();

      if (Game.loop) {
        window.setInterval(Game.loop, 20);
      }
    </script>
  </body>
</html>
EOF

fancy_echo "Creating initial js & css files"
cat << EOF > ./src/css/index.scss
body {

}
EOF
cat << EOF > ./src/index.js
const windowWidth = window.innerWidth;
const backgroundHeight = 200;
const colors = [
  "rgb(204, 36, 29)",
  "rgb(152, 151, 26)",
  "rgb(215, 153, 33)",
  "rgb(69, 133, 136)",
  "rgb(177, 98, 134)",
  "rgb(104, 157, 106)",
  "rgb(214, 93, 14)",
];

function getDimensions(max, min, variance) {
  const height = randomDimension(max, min);
  const width = constrainedRandomDimension(height, variance);
  return { height, width };
}

function randomDimension(max, mod) {
  return Math.floor(Math.random() * max + mod);
}

function constrainedRandomDimension(constraint, variance) {
  const max = constraint + variance;
  return Math.floor(
    Math.random() * (max - (constraint - variance)) + constraint - variance
  );
}

function renderScene() {
  document.body.style.backgroundColor = "lightgrey";
  const targetElement = document.getElementById("code-for-fun");

  const splashBackground = document.createElement("div");
  splashBackground.classList.add("code-for-fun-splash-background");
  targetElement.appendChild(splashBackground);
  const splashContainer = document.createElement("div");
  splashContainer.classList.add("code-for-fun-splash-container");
  targetElement.appendChild(splashContainer);

  const splashTextbox = document.createElement("div");
  splashTextbox.classList.add("code-for-fun-splash-textbox");
  splashTextbox.innerText =
    "Coding is fun!\n\nStart your game with a " +
    "Game.setup function to remove this window!";

  splashContainer.appendChild(splashTextbox);
}

function createBox({
  minSize = 50,
  maxSize = 200,
  posWidth = window.innerWidth,
  posHeight = 200,
  variance = 25,
}) {
  const box = document.createElement("div");
  box.classList.add("code-for-fun-bg-block");

  const dimensions = getDimensions(maxSize, minSize, variance);
  box.style.height = dimensions.height.toString() + "px";
  box.style.width = dimensions.width.toString() + "px";

  const colorIndex = Math.floor(Math.random() * colors.length);
  box.style.backgroundColor = colors[colorIndex];

  const leftEdge = Math.floor(Math.random() * (windowWidth + 20) - 10);
  const topEdge = Math.floor(Math.random() * (backgroundHeight + 20) - 10);
  const rightEdge = leftEdge + dimensions.width;
  const bottomEdge = topEdge + dimensions.height;

  box.style.left = leftEdge.toString() + "px";
  box.style.top = topEdge.toString() + "px";

  return {
    element: box, leftEdge, rightEdge, topEdge, bottomEdge
  };
}

Game.setup = function() {
  renderScene();
  const splashBackground = document.querySelector(
    ".code-for-fun-splash-background",
  );

  const windowWidth = window.innerWidth;
  const backgroundHeight = 200;
  const squares = [];
  const littleSquares = [];
  let attempts = 0;
  let shouldContinue = true;
  while (shouldContinue) {
    const box = createBox({});

    let overlapping = false;
    for (let j = 0, l = squares.length; j < l; j++) {
      const compareSquare = squares[j].element;
      const boundingRect = compareSquare.getBoundingClientRect();

      if (
        box.leftEdge < boundingRect.right + 2 &&
        box.rightEdge > boundingRect.left - 2 &&
        (box.topEdge < boundingRect.bottom + 2 && box.bottomEdge > boundingRect.top - 2)
      ) {
        overlapping = true;
      }
    }

    if (!overlapping) {
      squares.push(box);
      splashBackground.appendChild(box.element);
    }

    attempts++;
    if (squares.length >= 50 || attempts >= 100) {
      shouldContinue = false;
    }
  }

  attempts = 0;
  shouldContinue = true;
  while (shouldContinue) {
    const box = createBox({
      minSize: 10,
      maxSize: 40,
      variance: 5,
    });

    let overlapping = false;
    for (let j = 0, l = squares.length; j < l; j++) {
      const compareSquare = squares[j].element;
      const boundingRect = compareSquare.getBoundingClientRect();

      if (
        box.leftEdge < boundingRect.right + 2 &&
        box.rightEdge > boundingRect.left - 2 &&
        (box.topEdge < boundingRect.bottom + 2 && box.bottomEdge > boundingRect.top - 2)
      ) {
        overlapping = true;
      }
    }
    for (let j = 0, l = littleSquares.length; j < l; j++) {
      const compareSquare = littleSquares[j].element;
      const boundingRect = compareSquare.getBoundingClientRect();

      if (
        box.leftEdge < boundingRect.right + 2 &&
        box.rightEdge > boundingRect.left - 2 &&
        (box.topEdge < boundingRect.bottom + 2 && box.bottomEdge > boundingRect.top - 2)
      ) {
        overlapping = true;
      }
    }

    if (!overlapping) {
      littleSquares.push(box);
      splashBackground.appendChild(box.element);
    }

    attempts++;
    if (squares.length >= 50 || attempts >= 300) {
      shouldContinue = false;
    }

  }

  setInterval(() => {
    const boxIndex = Math.floor(Math.random() * squares.length);
    const changingSquare = squares[boxIndex].element;
    let newColor = undefined;
    newColor = colors[Math.floor(Math.random() * colors.length)];
    while (newColor === changingSquare.style.backgroundColor) {
      newColor = colors[Math.floor(Math.random() * colors.length)];
    }
    changingSquare.style.backgroundColor = newColor;
  }, 1500);
};
EOF
fancy_echo "Creating babelrc"

cat << EOF > ./.babelrc
{
  "presets": ["@babel/preset-env"]
}
EOF

fancy_echo "Creating dev Server code"
cat << 'EOF' > ./devServer.js
const chokidar = require("chokidar");
const http = require("http");
const fs = require("fs");
const WebSocketServer = require("websocket").server;
const {exec} = require("child_process");

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

server.listen(devServer.port, devServer.hostname, () => {
  console.log(`Server running on http://${devServer.hostname}:${devServer.port}\n`);
});
EOF
yarn add -D @babel/core @babel/cli @babel/preset-env mocha chai chokidar websocket
