module Terakoya
  module ApplicationHelper
    def event_status_color(status)
      case status.to_s
      when "draft" then "secondary"
      when "pending" then "warning"
      when "confirmed" then "success"
      when "cancelled" then "danger"
      when "completed" then "info"
      else "secondary"
      end
    end

    def event_type_icon(event_type)
      case event_type.to_s
      when "booking" then "📅"
      when "class_session" then "🎓"
      when "office_hours" then "⏰"
      when "personal" then "👤"
      when "block" then "🚫"
      else "📌"
      end
    end

    def mode_badge(mode)
      color = mode == "partner" ? "primary" : "success"
      content_tag :span, t("terakoya.modes.#{mode}"), class: "badge bg-#{color}"
    end

    def format_duration(minutes)
      hours = minutes / 60
      mins = minutes % 60

      if hours > 0 && mins > 0
        "#{hours}h #{mins}m"
      elsif hours > 0
        "#{hours}h"
      else
        "#{mins}m"
      end
    end

    def calendar_color_for(event_type)
      case event_type.to_s
      when "booking" then "#3788d8"
      when "class_session" then "#22c55e"
      when "office_hours" then "#eab308"
      when "personal" then "#8b5cf6"
      when "block" then "#6b7280"
      else "#3788d8"
      end
    end
  end
end
