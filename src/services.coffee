express = require('express')

app = express.createServer() #express.logger()
app.use(express.static(__dirname + '/public'))
app.use express.cookieParser()
app.use express.session
  secret: 'viperservices'

io = require('socket.io').listen app

io.configure 'development', ->
  io.set 'log level', 1
  
io.configure 'production', ->
  io.set 'log level', 1

viper =
  version: '0.1'
  status: 'status'
  users: 'users'
  games: 'games'

games = {}
gamescount = 0

countStartedGames = ->
  count = 0;    
  for key, game of games
    if game.started then count++
  return count

countWaitingGames = ->
  count = 0;    
  for key, game of games
    if game.waiting then count++
  return count;

# root resource
app.get "/", (request, response) ->
  root =
    version: viper.version
    status: viper.status
    users: viper.users
    games: viper.games
    sessionID: request.sessionID
  response.send root

# get service status
app.get "/#{viper.status}", (request, response) ->
  status =
    usersCount: Object.keys(request.sessionStore.sessions).length
    gamesWaitingCount: countWaitingGames()
    gamesStartedCount: countStartedGames()
  response.send status

# get random game id
app.get "/#{viper.games}/random", (request, response) ->
  # TODO: make truly random
  for key of games
    response.send
      gameID: key
    break

# create game
app.post "/#{viper.games}", (request, response) ->
  sessionID = request.sessionID
  gameID = gamescount++
  
  game =
    waiting: true
    started: false
    players: {}

  games[gameID] = game
  console.log("Game #{gameID} created")
  response.send
    gameID: gameID

port = process.env.PORT || 80
app.listen port
# handle (web)socket connections
io.sockets.on 'connection', (socket) ->

  # handle join events from any client
  socket.on 'join', (data) ->
    game = games[data.gameID]
    game.players[data.sessionID] =
      socket: socket
    
    playerscount = Object.keys(game.players).length
    
    # send start signal to all players
    if playerscount>1
      for key, player of game.players
        player.socket.emit 'start'

  # handle move events from any player
  socket.on 'move', (data) ->
    sessionID = data.sessionID
    game = games[data.gameID]
    
    # send move to other players
    for key, player of game.players
      if key != sessionID
        player.socket.emit 'move'
          x: data.x
          y: data.y
          hole: data.hole
 
