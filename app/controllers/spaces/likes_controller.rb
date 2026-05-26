class Spaces::LikesController < Spaces::BaseController
  before_action :set_entry

  def create
    Current.user.likes.find_or_create_by!(likeable: @entry)
    respond_with_button
  end

  def destroy
    Current.user.likes.where(likeable: @entry).destroy_all
    respond_with_button
  end

  private
    def set_entry
      @entry = @space.entries.find(params[:entry_id])
    end

    def respond_with_button
      respond_to do |format|
        format.turbo_stream do
          render turbo_stream: turbo_stream.replace(
            "entry-like-#{@entry.id}",
            partial: "spaces/entries/like_button",
            locals: { entry: @entry.reload }
          )
        end
        format.html { redirect_back fallback_location: space_entry_path(@space, @entry) }
      end
    end
end
