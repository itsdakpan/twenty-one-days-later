module ApplicationHelper
  AVATAR_SIZES = { sm: "avatar--sm", md: nil, lg: "avatar--lg" }.freeze

  # Uploaded photo if there is one, otherwise the user's initials.
  # url_for works with both Cloudinary (production) and local disk (development).
  def avatar_for(user, size: :md)
    classes = ["avatar", AVATAR_SIZES[size]].compact.join(" ")
    if user.photo.attached?
      image_tag url_for(user.photo), class: classes, alt: user.display_name, loading: "lazy"
    else
      content_tag :span, user.initials, class: classes, aria: { label: user.display_name }, role: "img"
    end
  end

  def nav_link(label, path, icon:)
    classes = current_page?(path) ? "is-active" : nil
    link_to path, class: classes, aria: { current: (current_page?(path) ? "page" : nil) } do
      safe_join([tag.i(class: "fa-solid #{icon}", aria: { hidden: true }), " ", tag.span(label)])
    end
  end

  def goal_status_tag(goal)
    return tag.span("No challenge yet", class: "status") unless goal

    case goal.status
    when :upcoming
      tag.span("Starts in #{pluralize(goal.days_until_start, 'day')}", class: "status")
    when :active
      tag.span("Day #{goal.current_day} of #{Goal::CHALLENGE_DAYS}", class: "status status--active")
    else
      tag.span(safe_join([tag.i(class: "fa-solid fa-check", aria: { hidden: true }), "Finished"], " "), class: "status status--finished")
    end
  end
end
