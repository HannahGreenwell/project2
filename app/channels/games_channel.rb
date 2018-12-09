# Define the games channel which inherits from ./application_cable/channel.rb

class GamesChannel < ApplicationCable::Channel
  # Responsible for subscribing to and streaming messages that are broadcast to this channel
  # Invoked in app/assets/javascripts/channels/games.js when subscription is created
  def subscribed
    stream_from 'games'
  end

  # TO DO
  def unsubscribed
  end

  # Listen for messages that are being sent from the front-end
  # (either app/assets/javascripts/channels/games.js or app/views/games/*)

  # Handles message broadcast from games.js. Finds the current game from the
  # id sent in the message and updates the games status to playing. Broadcasts
  # a message to games.js that the game is ready to begin.
  def guesser_ready(data)
    game = Game.find data['game_id']
    game.update status: 'playing'
    ActionCable.server.broadcast 'games', status: 'playing'
  end

  # Handles message broadcast from _canvas_js_guesser.html.erb.
  # Broadcasts a message to games.js that game has finished.
  def game_over(data)
    ActionCable.server.broadcast 'games', status: 'finished'
  end

  # Handles message broadcast from _canvas_js_common.html.erb.
  # Broadcasts a message to games.js containing x and y coordinates
  # and the event type (click)
  def drawer_clicked(data)
    ActionCable.server.broadcast 'games', event: data['event'], position: {xPos: data['position']['xPos'], yPos: data['position']['yPos']}
  end

  # Handles message broadcast from _canvas_js_common.html.erb.
  # Broadcasts a message to games.js containing x and y coordinates
  # and the event type (mouseenter)
  def drawer_entered(data)
    ActionCable.server.broadcast 'games', event: data['event'], position: {xPos: data['position']['xPos'], yPos: data['position']['yPos']}
  end

  # Handles message broadcast from _canvas_js_common.html.erb.
  # Broadcasts a message to games.js containing x and y coordinates,
  # the event type (mousemove), and the key pressed (userInput)
  def drawer_moved(data)
    ActionCable.server.broadcast 'games', event: data['event'], position: {xPos: data['position']['xPos'], yPos: data['position']['yPos']}, userInput: data['userInput']
  end

  # Handles message broadcast from _canvas_js_drawer.html.erb.
  # Broadcasts a message to games.js to clear the canvas.
  def clear_canvas(data)
      ActionCable.server.broadcast 'games', clear: true
  end
end
