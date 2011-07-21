express = require 'express'

app = express.createServer()
app.use(express.static(__dirname + '/public', {maxAge: 604800000}))
app.use express.cookieParser()
app.use express.session
  secret: 'viperservices'

io = require('socket.io').listen app

io.configure 'development', ->
  io.set 'log level', 0
  io.set 'browser client etag', true
  io.set 'browser client minification', true

io.configure 'production', ->
  io.set 'log level', 0
  io.set 'browser client etag', true
  io.set 'browser client minification', true

viper =
  version: '0.1'
  status: 'status'
  users: 'users'
  games: 'games'

games = {}
gamescount = 0

countStartedGames = ->
  count = 0
  for key, game of games
    if game.started then count++
  return count

countWaitingGames = ->
  count = 0
  for key, game of games
    if game.waiting then count++
  return count;

# root resource
app.get "/", (request, response) ->
  response.send
    version: viper.version
    status: viper.status
    users: viper.users
    games: viper.games
    sessionID: request.sessionID
    
# get service status
app.get "/#{viper.status}", (request, response) ->    
  response.send
    usersCount: Object.keys(request.sessionStore.sessions).length
    gamesWaitingCount: countWaitingGames()
    gamesStartedCount: countStartedGames()

# get random game waiting id
app.get "/#{viper.games}/random", (request, response) ->
  # TODO: make truly random
  for key, game of games
    if game.waiting
      response.send
        success: true
        gameID: key
      return
  response.send
    success: false

# create game
app.post "/#{viper.games}", (request, response) ->
  sessionID = request.sessionID
  gameID = gamescount++
  
  games[gameID] =
    waiting: true
    started: false
    players: {}
    
  console.log "Game #{gameID} created."
  
  response.send
    success: true
    gameID: gameID

port = process.env.PORT || 80
app.listen port

# handle (web)socket connections
io.sockets.on 'connection', (socket) ->

  # handle disconnects
  socket.on 'disconnect', ->
    for gameKey, game of games
      players = []
      disconnected = false
      for playerKey, player of game.players
        if player.socket is socket
          console.log "Player disconnected from #{gameKey}, deleting game."
          disconnected = true
        else
          players.push player
      
      if disconnected
        for player in players
          console.log "Telling other players game is over with status 3."
          player.socket.emit 'gameover', 3
        console.log "Deleting game #{gameKey}."
        delete games[gameKey]

  # handle join events from any client
  socket.on 'join', (data) ->
    game = games[data.gameID]
    game.players[data.sessionID] =
      socket: socket
    
    playerscount = Object.keys(game.players).length
    
    console.log "Player joined game #{data.gameID}."
    
    # send start signal to all players
    if playerscount > 1
      console.log "Starting game #{data.gameID}."
      game.started = true
      game.waiting = false
      for key, player of game.players
        player.socket.emit 'start'

  # handle move events from any player
  socket.on 'move', (data) ->
    sessionID = data.sessionID
    gameID = data.gameID
    game = games[gameID]
    
    if not game? then return
    
    # send move to other players
    for key, player of game.players
      if key isnt sessionID
        player.socket.emit 'move'
          x: data.x
          y: data.y
          hole: data.hole
    
    game.players[sessionID].alive = data.alive
    game.players[sessionID].score = data.score
    
    gameover = true
    for key, player of game.players
      if player.alive then gameover = false
    
    gameResult = (playerKey) =>
      players = []
      scores = []
      for key, player of game.players
        players.push key
        scores.push player.score
      
      if scores[0] is scores[1]
        return 0
      else if scores[0] > scores[1] and playerKey is players[0]
        return 1
      else if scores[1] > scores[0] and playerKey is players[1]
        return 1
      else 
        return 2
        
    if gameover
      console.log "Game #{gameID} ended."
      for key, player of game.players
        player.socket.emit 'gameover', gameResult(key)
          
      delete games[gameID]

