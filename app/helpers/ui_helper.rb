module UiHelper
  BUTTON_BASE = "inline-flex items-center justify-center font-medium text-sm rounded-md border transition duration-300 ease-out " \
                "focus:outline-none focus-visible:ring-2 focus-visible:ring-accent focus-visible:ring-offset-2 focus-visible:ring-offset-paper " \
                "disabled:opacity-50 disabled:cursor-not-allowed disabled:hover:translate-y-0 cursor-pointer"

  BUTTON_VARIANTS = {
    primary: "bg-accent text-accent-contrast border-accent hover:bg-accent-soft hover:-translate-y-0.5 active:translate-y-0",
    secondary: "bg-transparent text-ink border-ink-soft/20 hover:bg-panel",
    ghost: "bg-transparent text-ink border-transparent hover:bg-panel",
    danger: "bg-danger text-white border-danger hover:opacity-90"
  }.freeze

  def button_classes(variant: :primary, extra: nil, icon_only: false)
    padding = icon_only ? "p-2.5" : "px-4 py-2"
    [ BUTTON_BASE, padding, BUTTON_VARIANTS.fetch(variant), extra ].compact.join(" ")
  end

  INPUT_BASE = "rounded-sm border bg-panel py-2 text-sm text-ink " \
               "focus:border-accent focus:outline-none focus:ring-1 focus:ring-accent"

  def input_classes(extra: nil, error: false)
    border_color = error ? "border-red-500" : "border-ink-soft/30"
    [ INPUT_BASE, border_color, extra ].compact.join(" ")
  end

  HANDLE_FIELD_STATE_CLASSES = "data-[suggested=taken]:border-accent-yellow! " \
                               "data-[suggested=taken]:text-accent-yellow! " \
                               "data-[suggested=free]:border-accent-emerald!".freeze

  def handle_field_classes
    HANDLE_FIELD_STATE_CLASSES
  end

  def user_initials(user)
    source = user.name.presence || user.handle
    parts  = source.to_s.strip.split(/\s+/)
    letters = parts.size >= 2 ? parts[0..1].map { |p| p.first } : source.chars.first(2)
    letters.join.upcase
  end

  def icon(name, variant: :outline, size: 20, label: nil, **opts)
    source = read_icon(name, variant)
    doc = Nokogiri::HTML5::DocumentFragment.parse(source)
    svg = doc.at_css("svg")
    raise ArgumentError, "Invalid SVG for icon #{variant}/#{name}" unless svg

    svg["width"] = size.to_s
    svg["height"] = size.to_s

    extra_class = opts.delete(:class)
    svg["class"] = [ "inline-block shrink-0", extra_class ].compact.join(" ")

    if label
      svg["role"] = "img"
      svg["aria-label"] = label
      title = Nokogiri::XML::Node.new("title", doc)
      title.content = label
      svg.prepend_child(title)
    else
      svg["aria-hidden"] = "true"
      svg["focusable"] = "false"
    end

    opts.each { |k, v| svg[k.to_s.tr("_", "-")] = v.to_s }

    svg.to_html.html_safe
  end

  private
    def read_icon(name, variant)
      [
        Rails.root.join("app/assets/images/icons/#{variant}/#{name}.svg"),
        Rails.root.join("app/assets/images/icons/custom/#{variant}/#{name}.svg")
      ].each do |path|
        return path.read if path.exist?
      end
      raise ArgumentError, "Icon #{variant}/#{name} not found"
    end
end
