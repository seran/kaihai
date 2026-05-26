class Users::HandleSuggestionsController < ApplicationController
  allow_unauthenticated_access only: :show
  skip_before_action :ensure_setup_complete

  def show
    except_id = params[:except_user_id].presence&.to_i
    render json: { handle: User.suggest_handle(params[:handle], except_user_id: except_id) }
  end
end
