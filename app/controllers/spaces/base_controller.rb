class Spaces::BaseController < ApplicationController
  before_action :set_space

  private
    def set_space
      @space = Space.find_by!(handle: params[:space_handle])
    end

    def require_moderator
      head :forbidden unless Current.user&.can_manage_space?(@space)
    end
end
