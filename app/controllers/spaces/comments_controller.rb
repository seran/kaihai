class Spaces::CommentsController < Spaces::BaseController
  before_action :require_subscriber
  before_action :set_entry
  before_action :set_comment, only: :destroy
  before_action :require_destroyable, only: :destroy

  def create
    @comment = @entry.comments.build(user: Current.user, body: params.dig(:comment, :body))
    if @comment.save
      redirect_to space_entry_path(@space, @entry)
    else
      redirect_to space_entry_path(@space, @entry), alert: form_error_message(@comment)
    end
  end

  def destroy
    @comment.destroy!
    redirect_to space_entry_path(@space, @entry), notice: "Comment removed."
  end

  private
    def set_entry
      @entry = @space.entries.find(params[:entry_id])
    end

    def set_comment
      @comment = @entry.comments.find(params[:id])
    end

    def require_subscriber
      head :forbidden unless Current.user&.can_post_in?(@space)
    end

    def require_destroyable
      head :forbidden unless @comment.editable_by?(Current.user)
    end
end
