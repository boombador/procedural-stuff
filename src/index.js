'use strict';

require('ace-css/css/ace.css');
require('font-awesome/css/font-awesome.css');

const root = document.createElement('div');
root.id = 'elm-root';
document.body.appendChild(root);

const Elm = require('../elm-src/Main.elm').Elm;
const app = Elm.Main.init({
  node: root,
});

//export const meshResponseListener = cb => {
  //app.ports.emitMesh.subscribe(cb);
//};
//meshResponseListener(msg => { console.log(msg) });

//export const requestMesh = meshType => {
  //console.log(`making a mesh request: ${meshType}`);
  //app.ports.meshRequests.send(meshType);
//};

