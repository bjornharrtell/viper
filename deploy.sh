#!/bin/sh
cake build
coffee -o . -c src/services.coffee
NODE_ENV=development node services.js

