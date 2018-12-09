// Create a client-side subscriber (consumer) to our games channel

// Creating the subscription relies on some JS variables defined in the body of
// the document (such as role and currentGame), therefore we need to load it
// after the document is ready
$(document).ready(function() {

  // Only load this (sockets) code on the games play page
  if($('body.games.play').length) {

    // Add our new subscription to our consumer and then
    // subscriptions.create invokes subscribed method in games_channel.rb
    App.games = App.cable.subscriptions.create('GamesChannel', {

      // Action to take after a successful subscription to the games channel
      connected: function() {
        // Once the guesser has successfully subscribed to the channel,
        // broadcast a JSON message containing the current game's id
        // (set in _canvas_js_common.html.rb)
        // Note: 'guesser_ready' refers to corresponding method in games_channel.rb
        if(role === 'guesser') {
          App.games.perform('guesser_ready', {game_id: currentGame});
        }
      },

      // Action to take after a sockets message has been received
      received: function(data) {

        // Handles messages about the game's status received from games_channel.rb
        if(data.status) {
          // Actions to take when a game is commencing
          if(data.status === 'playing') {
            // Clear the drawer's canvas before the game starts
            canvasApp.clearCanvas();

            // Change the text displayed on the drawer's page
            $('h2.drawer_wait').hide();
            $('h2.drawer_play').show();

            // Set and display a countdown timer for both players
            let timeLeft = 30;

            const gameTimer = setInterval(function() {
              $('div.timer').text(`Time left: ${timeLeft}`);

              // When the countdown timer reaches zero clear the timer
              if(timeLeft <= 0) {
                $('div.timer').empty();
                clearInterval(gameTimer);
                // If the guesser's timer reaches zero, call the gameOver
                // function in _canvas_js_guesser.html.erb to record a loss
                if(role === 'guesser') {
                  gameOver('lost');
                }
              }

              timeLeft -= 1;
            }, 1000);
          }
          // Actions to take when a game finishes
          else if (data.status === 'finished') {
            // Redirect to the games result path using the variable set-up in
            // _canvas_js_common.html.erb, wait 3 seconds for Cloudinary image upload
            setTimeout(function() { window.location.href = gameOverRedirectURL }, 3000);
          } else {
            // TO DO: Catch any waiting or cancelled games
          }
        }

        // Handles messages about the drawing and broadcasts to the guesser
        if(data.position && role === 'guesser') {

          // Handles click events
          if(data.event === 'click') {
            // Passes xPos and yPos from the socket message to setPosition and
            // drawOnClick canvas methods in _canvas_js_common.html.erb
            canvasApp.setPosition(data.position.xPos, data.position.yPos);
            canvasApp.drawOnClick();
          // Handles mouseenter event
          } else if (data.event === 'mouseenter') {
            // Passes xPos and yPos from the socket message to setPosition
            // method in _canvas_js_common.html.erb
            canvasApp.setPosition(data.position.xPos, data.position.yPos);
          // Handles mousemove event
          } else {
            // Passes xPos, yPos and the key pressed (userInput) from the
            // socket message to drawOnMove method in _canvas_js_common.html.erb
            canvasApp.drawOnMove(data.userInput, data.position.xPos, data.position.yPos)
          }
        }

        // Handles a clear canvas message
        if(data.clear) {
          canvasApp.clearCanvas();
        }
      },
    });
  }
});
