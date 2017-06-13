'use strict';

import render from './procedural.js';

require('ace-css/css/ace.css');
require('font-awesome/css/font-awesome.css');

const Elm = require('../elm-src/Main.elm');

const create = nodeType => {
  const elem = document.createElement(nodeType)
  document.body.appendChild(elem);
  return elem;
}

const elmMountNode = create('div');
const requestButton = create('button');
requestButton.innerHTML = 'Make a request';


const app = Elm.Main.embed(elmMountNode);

export const meshResponseListener = cb => {
  app.ports.emitMesh.subscribe(cb);
};

export const requestMesh = meshType => {
  console.log(`making a mesh request: ${meshType}`);
  app.ports.meshRequests.send(meshType);
};

requestButton.addEventListener('click', () => requestMesh('thing'));

meshResponseListener(msg => {
  console.log(msg)
});

// invoke this function to start the event loop for the old three.js implementation
render();
