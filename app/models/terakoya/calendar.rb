module Terakoya
  class Calendar < ApplicationRecord
    # Associations
    belongs_to :owner, polymorphic: true
    has_many :events, class_name: "Terakoya::Event", dependent: :destroy

    # Validations
    validates :calendar_type, presence: true, inclusion: { in: %w[leader partner] }
    validates :timezone, presence: true
    validates :owner_type, presence: true
    validates :owner_id, presence: true, uniqueness: { scope: [:owner_type, :calendar_type] }
    validates :default_event_duration, numericality: { greater_than: 0 }
    validates :buffer_time, numericality: { greater_than_or_equal_to: 0 }
    validates :advance_booking_days, numericality: { greater_than: 0 }
    validates :minimum_notice_hours, numericality: { greater_than_or_equal_to: 0 }

    # Scopes
    scope :leader_calendars, -> { where(calendar_type: "leader") }
    scope :partner_calendars, -> { where(calendar_type: "partner") }
    scope :public_calendars, -> { where(is_public: true) }

    # Instance methods
    def upcoming_events
      events.where("start_time >= ?", Time.current)
            .order(:start_time)
    end

    def past_events
      events.where("end_time < ?", Time.current)
            .order(start_time: :desc)
    end

    def events_for_date(date)
      start_of_day = date.in_time_zone(timezone).beginning_of_day
      end_of_day = date.in_time_zone(timezone).end_of_day

      events.where("start_time >= ? AND start_time <= ?", start_of_day, end_of_day)
            .order(:start_time)
    end

    def events_for_range(start_date, end_date)
      events.where("start_time >= ? AND start_time <= ?", start_date, end_date)
            .order(:start_time)
    end

    def available_slots(date, duration: nil)
      duration ||= default_event_duration
      # This will be implemented more fully with availability checking logic
      []
    end

    def is_available?(start_time, end_time)
      # Check if there are any conflicting events
      conflicts = events.where(
        "(start_time < ? AND end_time > ?) OR (start_time < ? AND end_time > ?) OR (start_time >= ? AND end_time <= ?)",
        end_time, start_time, end_time, end_time, start_time, end_time
      ).exists?

      !conflicts
    end

    def leader_calendar?
      calendar_type == "leader"
    end

    def partner_calendar?
      calendar_type == "partner"
    end

    def display_name
      name.presence || "#{owner.display_name}'s Calendar"
    end
  end
end
