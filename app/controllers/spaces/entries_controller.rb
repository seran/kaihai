class Spaces::EntriesController < Spaces::BaseController
  before_action :require_subscriber, only: %i[ new create ]
  before_action :set_entry,          only: %i[ show edit update destroy ]
  before_action :require_editable,   only: %i[ edit update destroy ]

  ENTRYABLE_TYPES = %w[ Post Event Poll ].freeze

  def index
    @entries = @space.entries.includes(:author, :entryable, latest_comment: :user).newest_first
  end

  def show
  end

  def new
    @entry      = @space.entries.build(author: Current.user)
    @entryables = build_blank_entryables
    @type       = requested_type || "Post"
  end

  def create
    @type = requested_type
    return head :bad_request unless @type

    entryable = @type.constantize.new(entryable_params)
    @entry    = @space.entries.build(author: Current.user, entryable: entryable)

    if @entry.save
      redirect_to space_entry_path(@space, @entry), notice: "Posted."
    else
      @entryables = build_blank_entryables.merge(@type => entryable)
      flash.now[:alert] = form_error_message(entryable.errors.any? ? entryable : @entry)
      render :new, status: :unprocessable_entity
    end
  end

  def edit
  end

  def update
    if @entry.entryable.update(entryable_params)
      redirect_to space_entry_path(@space, @entry), notice: "Updated."
    else
      flash.now[:alert] = form_error_message(@entry.entryable)
      render :edit, status: :unprocessable_entity
    end
  end

  def destroy
    @entry.destroy!
    redirect_to space_entries_path(@space), notice: "Removed."
  end

  private
    def set_entry
      @entry = @space.entries.includes(:author, :entryable).find(params[:id])
    end

    def require_subscriber
      head :forbidden unless Current.user&.can_post_in?(@space)
    end

    def require_editable
      head :forbidden unless @entry.editable_by?(Current.user)
    end

    def requested_type
      ENTRYABLE_TYPES.include?(params[:type]) ? params[:type] : nil
    end

    def build_blank_entryables
      {
        "Post"  => Post.new,
        "Event" => Event.new,
        "Poll"  => Poll.new(poll_options: Array.new(2) { PollOption.new })
      }
    end

    def entryable_params
      type = action_name == "update" ? @entry.entryable_type : @type
      case type
      when "Post"
        params.require(:post).permit(:body)
      when "Event"
        params.require(:event).permit(:description, :starts_at, :location)
      when "Poll"
        params.require(:poll).permit(:question, :description, poll_options_attributes: %i[ id body _destroy ])
      end
    end
end
