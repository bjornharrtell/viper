#!/bin/sh
cake build
cp lib/viper.js public/lib
coffee -o . -c src/services.coffee
NODE_ENV=development node services.js

