fs     = require 'fs'
{exec} = require 'child_process'

appFiles  = [
  'MainMenu'
  'WormSegment'
  'Worm'
  'Viper'
]

task 'build', 'Build single application file from source files', ->
  appContents = new Array remaining = appFiles.length
  for file, index in appFiles then do (file, index) ->
    fs.readFile "src/#{file}.coffee", 'utf8', (err, fileContents) ->
      throw err if err
      appContents[index] = fileContents
      process() if --remaining is 0
  process = ->
    fs.writeFile 'public/lib/viper.coffee', appContents.join('\n\n'), 'utf8', (err) ->
      throw err if err
      exec 'coffee --compile public/lib/viper.coffee', (err, stdout, stderr) ->
        throw err if err
        console.log stdout + stderr
        fs.unlink 'public/lib/viper.coffee', (err) ->
          throw err if err
          console.log 'Done.'

task 'minify', 'Minify the resulting application file after build', ->
  exec 'java -jar "compiler.jar" --js public/lib/viper.js --compilation_level ADVANCED_OPTIMIZATIONS --js_output_file public/lib/viper-min.js', (err, stdout, stderr) ->
    throw err if err
    console.log stdout + stderr

