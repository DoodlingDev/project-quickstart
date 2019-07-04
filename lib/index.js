const windowWidth = window.innerWidth;
const backgroundHeight = 200;
const colors = ["rgb(204, 36, 29)", "rgb(152, 151, 26)", "rgb(215, 153, 33)", "rgb(69, 133, 136)", "rgb(177, 98, 134)", "rgb(104, 157, 106)", "rgb(214, 93, 14)"];

function getDimensions(max, min, variance) {
  const height = randomDimension(max, min);
  const width = constrainedRandomDimension(height, variance);
  return {
    height,
    width
  };
}

function randomDimension(max, mod) {
  return Math.floor(Math.random() * max + mod);
}

function constrainedRandomDimension(constraint, variance) {
  const max = constraint + variance;
  return Math.floor(Math.random() * (max - (constraint - variance)) + constraint - variance);
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
  splashTextbox.innerText = "Coding is fun!\n\nStart your game with a " + "Game.setup function to remove this window!";
  splashContainer.appendChild(splashTextbox);
}

function createBox({
  minSize = 50,
  maxSize = 200,
  posWidth = window.innerWidth,
  posHeight = 200,
  variance = 25
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
    element: box,
    leftEdge,
    rightEdge,
    topEdge,
    bottomEdge
  };
}

Game.setup = function () {
  renderScene();
  const splashBackground = document.querySelector(".code-for-fun-splash-background");
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

      if (box.leftEdge < boundingRect.right + 2 && box.rightEdge > boundingRect.left - 2 && box.topEdge < boundingRect.bottom + 2 && box.bottomEdge > boundingRect.top - 2) {
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
      variance: 5
    });
    let overlapping = false;

    for (let j = 0, l = squares.length; j < l; j++) {
      const compareSquare = squares[j].element;
      const boundingRect = compareSquare.getBoundingClientRect();

      if (box.leftEdge < boundingRect.right + 2 && box.rightEdge > boundingRect.left - 2 && box.topEdge < boundingRect.bottom + 2 && box.bottomEdge > boundingRect.top - 2) {
        overlapping = true;
      }
    }

    for (let j = 0, l = littleSquares.length; j < l; j++) {
      const compareSquare = littleSquares[j].element;
      const boundingRect = compareSquare.getBoundingClientRect();

      if (box.leftEdge < boundingRect.right + 2 && box.rightEdge > boundingRect.left - 2 && box.topEdge < boundingRect.bottom + 2 && box.bottomEdge > boundingRect.top - 2) {
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
