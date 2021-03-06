class WordsController < ApplicationController
  def index
    @words = Word.all.order(:word)
    @games = Game.all.sample(6)
  end

  def show
    render json: Word.find(params[:id]).games
  end
end
