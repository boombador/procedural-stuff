# Procedural Geometry in Elm

This project uses elm to generate meshes for use with 
[elm-explorations/webgl](https://github.com/elm-explorations/webgl).

No guarantees for your production server.

## Setup

Development currently assumes yarn, which you may install via `npm`:

    npm install -g yarn

`npm` may also work as an untested substitute. With your package manager
of choice, install the project's `node_modules`:

    yarn install

This makes use of the `elm-webpack-loader`
[project](https://www.npmjs.com/package/elm-webpack-loader) so you can leverage
your webpack skillz.

## Running

Start the server, then go to [localhost:3000]() (or your custom development IP at the
same port):

    yarn start
