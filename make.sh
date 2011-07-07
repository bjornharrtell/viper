#!/bin/sh
rm lib/viper.js
coffee -j lib/viper.js -c src/Point.coffee src/Line.coffee src/WormSegment.coffee src/Worm.coffee src/Viper.coffee

