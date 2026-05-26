class SpacesController < ApplicationController
  before_action :set_space, only: :show

  FILTERS = %w[ all open private subscribed favorites ].freeze

  def index
    @filter = FILTERS.include?(params[:filter]) ? params[:filter] : "all"
    @spaces = filtered_spaces(@filter).alphabetical
  end

  def show
    @recent_subscriptions = @space.recent_subscriptions
    @entries = @space.entries.includes(:author, :entryable, latest_comment: :user).newest_first.limit(20)
  end

  def new
    @space = Space.new
  end

  def create
    @space = Space.new(space_params.merge(creator: Current.user))
    Space.transaction do
      if @space.save
        @space.subscriptions.create!(user: Current.user, role: :moderator)
      end
    end

    if @space.persisted?
      respond_to do |format|
        format.turbo_stream do
          render turbo_stream: [
            turbo_stream.update("new-space-form", partial: "spaces/form", locals: { space: Space.new, in_modal: true }),
            turbo_stream.remove("spaces-empty"),
            turbo_stream.prepend("spaces-grid", partial: "spaces/card", locals: { space: @space }),
            turbo_stream.append("toaster", partial: "shared/ui/toast",
                                locals: { variant: :success, message: "Space created." })
          ]
        end
        format.html { redirect_to space_path(@space), notice: "Space created." }
      end
    else
      respond_to do |format|
        format.turbo_stream do
          render turbo_stream: [
            turbo_stream.update("new-space-form", partial: "spaces/form", locals: { space: @space, in_modal: true }),
            form_error_toast(@space)
          ], status: :unprocessable_entity
        end
        format.html do
          flash.now[:alert] = form_error_message(@space)
          render :new, status: :unprocessable_entity
        end
      end
    end
  end

  private
    def filtered_spaces(filter)
      case filter
      when "open"       then Space.where(visibility: :open)
      when "private"    then Space.where(visibility: :private)
      when "subscribed" then Current.user.spaces
      when "favorites"  then Current.user.favorite_spaces
      else                   Space.all
      end
    end

    def set_space
      @space = Space.find_by!(handle: params[:handle])
    end

    def space_params
      params.expect(space: %i[ name handle description visibility ])
    end
end
