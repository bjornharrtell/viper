#!/bin/sh
coffee -o . -c src/services.coffee
node services.js

