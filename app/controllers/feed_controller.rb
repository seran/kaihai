class FeedController < ApplicationController
  TYPES    = %w[ Post Event Poll ].freeze
  SORTS    = %w[ newest recent ].freeze
  PER_PAGE = 5

  def index
    @type = TYPES.include?(params[:type]) ? params[:type] : nil
    @sort = SORTS.include?(params[:sort]) ? params[:sort] : "newest"
    @page = [ params[:page].to_i, 1 ].max

    space_ids = Current.user.spaces.pluck(:id)
    scope     = Entry.where(space_id: space_ids).includes(:author, :space, :entryable, latest_comment: :user)
    scope     = scope.where(entryable_type: @type) if @type
    scope     = (@sort == "recent" ? scope.order(updated_at: :desc) : scope.order(created_at: :desc))

    rows      = scope.offset((@page - 1) * PER_PAGE).limit(PER_PAGE + 1).to_a
    @has_more = rows.size > PER_PAGE
    @entries  = rows.first(PER_PAGE)
  end
end
