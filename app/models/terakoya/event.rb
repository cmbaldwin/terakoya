module Terakoya
  class Event < ApplicationRecord
    # Associations
    belongs_to :calendar, class_name: "Terakoya::Calendar"
    belongs_to :creator, polymorphic: true
    belongs_to :terakoya_class, class_name: "Terakoya::Class", optional: true
    belongs_to :parent_event, class_name: "Terakoya::Event", optional: true
    has_many :child_events, class_name: "Terakoya::Event", foreign_key: :parent_event_id
    has_many :event_participants, class_name: "Terakoya::EventParticipant", dependent: :destroy
    has_many :participants, through: :event_participants, source: :participant, source_type: "Terakoya::Partner"
    has_many :notes, class_name: "Terakoya::Note", dependent: :nullify

    # Validations
    validates :title, presence: true
    validates :start_time, presence: true
    validates :end_time, presence: true
    validates :event_type, presence: true, inclusion: { in: %w[booking class_session office_hours personal block] }
    validates :visibility, presence: true, inclusion: { in: %w[public private class_only busy] }
    validates :status, presence: true, inclusion: { in: %w[draft pending confirmed cancelled completed] }
    validate :end_time_after_start_time

    # Callbacks
    before_validation :calculate_duration
    before_create :set_default_color

    # Scopes
    scope :upcoming, -> { where("start_time >= ?", Time.current).order(:start_time) }
    scope :past, -> { where("end_time < ?", Time.current).order(start_time: :desc) }
    scope :confirmed, -> { where(status: "confirmed") }
    scope :pending_approval, -> { where(status: "pending", requires_approval: true) }
    scope :for_date, ->(date) {
      where("DATE(start_time) = ?", date)
    }
    scope :for_range, ->(start_date, end_date) {
      where("start_time >= ? AND start_time <= ?", start_date, end_date)
    }
    scope :by_type, ->(type) { where(event_type: type) }
    scope :visible_to_public, -> { where(visibility: "public") }
    scope :bookable, -> { where(event_type: "booking", status: %w[draft confirmed]) }

    # Instance methods
    def confirm!
      update(status: "confirmed", confirmed_at: Time.current)
    end

    def cancel!(reason: nil)
      update(
        status: "cancelled",
        cancelled_at: Time.current,
        cancellation_reason: reason
      )
    end

    def complete!
      update(status: "completed", completed_at: Time.current)
    end

    def can_be_cancelled?
      return true unless cancellation_deadline_hours

      hours_until_event = ((start_time - Time.current) / 1.hour).round
      hours_until_event >= cancellation_deadline_hours
    end

    def can_be_rescheduled?
      return false if reschedule_limit && reschedule_count >= reschedule_limit
      can_be_cancelled?
    end

    def visible_to?(user_or_role)
      case visibility
      when "public"
        true
      when "private"
        is_creator?(user_or_role) || is_participant?(user_or_role)
      when "class_only"
        has_class_access?(user_or_role)
      when "busy"
        false # Only show as "busy" slot, no details
      else
        false
      end
    end

    def full_details_visible_to?(user_or_role)
      return true if visibility == "public"
      return true if is_creator?(user_or_role)
      return true if is_participant?(user_or_role)
      return true if visibility == "class_only" && has_class_access?(user_or_role)
      false
    end

    def masked_for?(user_or_role)
      !full_details_visible_to?(user_or_role)
    end

    def as_masked_json
      {
        id: id,
        start_time: start_time,
        end_time: end_time,
        title: "Busy",
        className: "event-busy",
        editable: false,
        extendedProps: {
          masked: true
        }
      }
    end

    def as_full_json
      {
        id: id,
        title: title,
        start: start_time.iso8601,
        end: end_time.iso8601,
        color: color,
        description: description,
        location: location,
        extendedProps: {
          event_type: event_type,
          visibility: visibility,
          status: status,
          meeting_link: meeting_link,
          creator_name: creator.display_name,
          class_name: terakoya_class&.name,
          masked: false
        }
      }
    end

    def at_capacity?
      capacity.present? && current_attendees >= capacity
    end

    def has_space?
      capacity.nil? || current_attendees < capacity
    end

    def duration_in_hours
      duration_minutes / 60.0
    end

    def reschedule_count
      metadata["reschedule_count"] || 0
    end

    private

    def is_creator?(user_or_role)
      return false unless user_or_role

      if user_or_role.is_a?(Terakoya::Leader) || user_or_role.is_a?(Terakoya::Partner)
        creator == user_or_role
      else
        false
      end
    end

    def is_participant?(user_or_role)
      return false unless user_or_role

      if user_or_role.is_a?(Terakoya::Partner)
        event_participants.exists?(participant: user_or_role)
      elsif user_or_role.is_a?(Terakoya::Leader)
        calendar.owner == user_or_role
      else
        false
      end
    end

    def has_class_access?(user_or_role)
      return false unless terakoya_class
      return false unless user_or_role

      if user_or_role.is_a?(Terakoya::Leader)
        terakoya_class.leader == user_or_role
      elsif user_or_role.is_a?(Terakoya::Partner)
        terakoya_class.partners.include?(user_or_role)
      else
        false
      end
    end

    def end_time_after_start_time
      return unless start_time && end_time

      if end_time <= start_time
        errors.add(:end_time, "must be after start time")
      end
    end

    def calculate_duration
      return unless start_time && end_time

      self.duration_minutes = ((end_time - start_time) / 60).to_i
    end

    def set_default_color
      self.color ||= case event_type
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
