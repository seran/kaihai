class ApplicationController < ActionController::Base
  include Authentication
  # Only allow modern browsers supporting webp images, web push, badges, import maps, CSS nesting, and CSS :has.
  allow_browser versions: :modern

  # Changes to the importmap will invalidate the etag for HTML responses
  stale_when_importmap_changes

  before_action :ensure_setup_complete, prepend: true
  around_action :with_user_time_zone

  helper_method :form_error_message

  private
    def with_user_time_zone(&block)
      Time.use_zone(Current.user&.time_zone || "UTC", &block)
    end

    def ensure_setup_complete
      redirect_to setup_path unless Current.account.configured?
    end

    # Standard message used for any form submission that fails validation.
    # Use the record's first error message when available; fall back to a
    # generic line otherwise.
    def form_error_message(record)
      record.errors.full_messages.first.presence || "Please fix the errors below."
    end

    # Build a turbo_stream that appends a danger toast describing a failed
    # form submission. Pair with a turbo_stream.replace of the form frame.
    def form_error_toast(record)
      turbo_stream.append("toaster",
                          partial: "shared/ui/toast",
                          locals: { variant: :danger, message: form_error_message(record) })
    end
end
