class Spaces::EventResponsesController < Spaces::BaseController
  before_action :require_subscriber
  before_action :set_event
  before_action :reject_if_past

  def create
    upsert
  end

  def update
    upsert
  end

  private
    def upsert
      response = @event.event_responses.find_or_initialize_by(user: Current.user)
      response.response = params.dig(:event_response, :response)
      if response.save
        respond_with_event(variant: :success, message: "Response saved.")
      else
        respond_with_event(variant: :danger, message: form_error_message(response))
      end
    end

    def respond_with_event(variant:, message:)
      entry = @event.entry
      respond_to do |format|
        format.turbo_stream do
          render turbo_stream: [
            turbo_stream.replace("event-details-#{@event.id}",
              partial: "spaces/entries/event_details",
              locals:  { entry: entry, event: @event }),
            turbo_stream.append("toaster",
              partial: "shared/ui/toast",
              locals:  { variant: variant, message: message })
          ]
        end
        format.html { redirect_back fallback_location: space_entry_path(@space, entry) }
      end
    end

    def set_event
      entry  = @space.entries.find(params[:entry_id])
      @event = entry.entryable
      head :not_found unless @event.is_a?(Event)
    end

    def require_subscriber
      head :forbidden unless Current.user&.can_post_in?(@space)
    end

    def reject_if_past
      return unless @event.past?
      redirect_back fallback_location: space_entry_path(@space, @event.entry), alert: "This event has ended."
    end
end
