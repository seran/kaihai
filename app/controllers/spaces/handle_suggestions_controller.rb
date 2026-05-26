class Spaces::HandleSuggestionsController < ApplicationController
  def show
    render json: { handle: Space.suggest_handle(params[:handle]) }
  end
end
