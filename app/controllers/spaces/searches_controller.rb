class Spaces::SearchesController < Spaces::BaseController
  before_action :require_member

  MAX_QUERY_LENGTH = 200

  def show
    @query = params[:q].to_s.strip.first(MAX_QUERY_LENGTH)
    @entries =
      if @query.present?
        Entry.matching(@query, space: @space)
             .includes(:author, :entryable, latest_comment: :user)
             .limit(50)
      else
        Entry.none
      end
  end

  private
    def require_member
      head :forbidden unless Current.user && @space.subscriber?(Current.user)
    end
end
