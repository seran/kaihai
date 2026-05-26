module ApplicationHelper
  FLASH_VARIANTS = {
    notice: :success,
    success: :success,
    alert: :danger,
    error: :danger,
    warning: :warning,
    info: :info
  }.freeze

  def flash_variant(type)
    FLASH_VARIANTS.fetch(type.to_sym, :info)
  end

  def app_name
    Current.account.name.presence || "Kaihai"
  end

  def app_tagline
    Current.account.tagline.presence || "a quiet community"
  end

  NOTIFICATION_PHRASES = {
    "wave"          => "waved at you",
    "comment"       => "left a comment",
    "space_request" => "requested to join a space you moderate"
  }.freeze

  def notification_phrase(notification)
    if notification.kind == "wave" && notification.notifiable.respond_to?(:reciprocal?) && notification.notifiable.reciprocal?
      "waved back at you"
    else
      NOTIFICATION_PHRASES.fetch(notification.kind, notification.kind)
    end
  end

  SEASONS = {
    (12..12) => "Winter", (1..2) => "Winter",
    (3..5)  => "Spring",
    (6..8)  => "Summer",
    (9..11) => "Autumn"
  }.freeze

  def season_for(date)
    SEASONS.find { |months, _| months.cover?(date.month) }&.last
  end

  def founded_label(date)
    "#{season_for(date)} · #{date.strftime('%B %Y')}"
  end
end
