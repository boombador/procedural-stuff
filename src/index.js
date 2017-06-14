'use strict';

import render from './procedural.js';

require('ace-css/css/ace.css');
require('font-awesome/css/font-awesome.css');

const Elm = require('../elm-src/Main.elm');

const app = Elm.Main.fullscreen();

//export const meshResponseListener = cb => {
  //app.ports.emitMesh.subscribe(cb);
//};
//meshResponseListener(msg => { console.log(msg) });

//export const requestMesh = meshType => {
  //console.log(`making a mesh request: ${meshType}`);
  //app.ports.meshRequests.send(meshType);
//};

