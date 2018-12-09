class GamesController < ApplicationController

  before_action :fetch_user

  def home
    render :home
  end

  def create
    # Check that the user is logged in
    unless @current_user.present?
      flash[:error] = "Please sign in to continue."
      redirect_to login_path
      return
    end

    # Get the last game
    last_game = Game.last

    # Check the status of the last game
    if last_game.status == 'waiting'
      # If the last game's status is 'waiting',
      # update last_game so that the current user
      # is the guesser then redirect to games#play
      # (When the guesser loads the play page a WebSockets message will
      # broadcast to the server, which will update the game's status to
      # 'playing' and tell the drawer the game has started.)
      last_game.update guesser: @current_user

      redirect_to game_play_path(last_game.id)
      return
    end

    # If the last game is not waiting for a guesser, then create a new game
    # Get a random word for the game
    random_word = Word.all.sample

    # Create a new game
    game = Game.new(
      drawer_id: @current_user.id,
      word_id: random_word.id,
      status: 'waiting'
    )

    # Save the new game and redirect to games#play
    if game.save
      redirect_to game_play_path(game.id)
    end
  end

  def play
    @game = Game.find params[:id]

    # Get the current user's role as a string
    @role = @game.get_role(@current_user)

    # Redirect users not logged in or games without a drawer
    if @role.nil?
       redirect_to root_path
    end

    render :play
  end

  def over
    render json: {status: 'ok'}

    @game = Game.find params[:id]

    response = Cloudinary::Uploader.upload(params[:drawingData])
    @game.update image: response["public_id"], result: params[:result], status: "finished"
  end

  def result
    @game = Game.find params[:id]
  end
end
