class Spaces::PollAnswersController < Spaces::BaseController
  before_action :require_subscriber

  def create
    @entry = @space.entries.find(params[:entry_id])
    @poll  = @entry.entryable
    return head :not_found unless @poll.is_a?(Poll)

    option = @poll.poll_options.find(params.dig(:poll_answer, :poll_option_id))
    @poll.poll_answers.create!(user: Current.user, poll_option: option)
    respond_with_results
  rescue ActiveRecord::RecordNotUnique, ActiveRecord::RecordInvalid
    respond_with_results
  end

  private
    def respond_with_results
      respond_to do |format|
        format.turbo_stream do
          render turbo_stream: turbo_stream.replace(
            "poll-vote-#{@poll.id}",
            partial: "spaces/entries/poll_vote",
            locals: { entry: @entry, poll: @poll.reload }
          )
        end
        format.html { redirect_back fallback_location: space_entry_path(@space, @entry) }
      end
    end

    def require_subscriber
      head :forbidden unless Current.user&.can_post_in?(@space)
    end
end
