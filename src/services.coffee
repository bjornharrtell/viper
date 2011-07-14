express = require('express');

app = express.createServer express.logger()
app.use(express.static(__dirname + '/public'));
app.use express.cookieParser()
app.use express.session
  secret: 'viperservices'

io = require('socket.io').listen app

viper =
  version: '0.1'
  status: 'status'
  users: 'users'
  games: 'games'

games = {}
gamescount = 0

countStartedGames = ->
  count = 0;    
  for key,game of games
    if game.started then count++
  return count

countWaitingGames = ->
  count = 0;    
  for key,game of games
    if game.waiting then count++
  return count;

app.get "/", (request, response) ->
  root =
    version: viper.version
    status: viper.status
    users: viper.users
    games: viper.games
    sessionID: request.sessionID
  response.send root

app.get "/#{viper.status}", (request, response) ->
  status =
    usersCount: Object.keys(request.sessionStore.sessions).length
    gamesWaitingCount: countWaitingGames()
    gamesStartedCount: countStartedGames()
  response.send status

app.get "/#{viper.games}", (request, response) ->
  response.send games

# get random game id
app.get "/#{viper.games}/random", (request, response) ->
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
  console.log("Game #{gameID} created.")
  response.send
    gameID: gameID

port = process.env.PORT || 3000;
app.listen port, ->
  console.log("Listening on " + port);

io.sockets.on 'connection', (socket) ->

  socket.on 'join', (data) ->
    console.log "Client #{data.sessionID} joining game #{data.gameID}."
    
    game = games[data.gameID]
    game.players[data.sessionID] =
      socket: socket
    
    playerscount = Object.keys(game.players).length
    
    if playerscount>1
      for key, player of game.players
        player.socket.emit 'start'

  socket.on 'move', (data) ->
    console.log "Move on game #{data.gameID} from  #{data.sessionID}."
    
    sessionID = data.sessionID;
    game = games[data.gameID]
    
    for key, player of game.players
        if key == sessionID then continue
        player.socket.emit 'move'
          worm: data.worm
          position: data.position
 

