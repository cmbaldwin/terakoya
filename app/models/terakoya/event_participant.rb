module Terakoya
  class EventParticipant < ApplicationRecord
    # Associations
    belongs_to :event, class_name: "Terakoya::Event"
    belongs_to :participant, polymorphic: true

    # Validations
    validates :role, presence: true, inclusion: { in: %w[organizer attendee optional] }
    validates :status, presence: true, inclusion: { in: %w[pending confirmed declined cancelled] }
    validates :participant_id, uniqueness: { scope: [:participant_type, :event_id] }

    # Callbacks
    after_create :send_invitation
    after_update :handle_status_change, if: :saved_change_to_status?

    # Scopes
    scope :pending, -> { where(status: "pending") }
    scope :confirmed, -> { where(status: "confirmed") }
    scope :declined, -> { where(status: "declined") }
    scope :organizers, -> { where(role: "organizer") }
    scope :attendees, -> { where(role: "attendee") }

    # Instance methods
    def confirm!
      update(status: "confirmed", response_at: Time.current)
    end

    def decline!
      update(status: "declined", response_at: Time.current)
    end

    def cancel!
      update(status: "cancelled")
    end

    def check_in!
      update(checked_in_at: Time.current)
    end

    def pending?
      status == "pending"
    end

    def confirmed?
      status == "confirmed"
    end

    def declined?
      status == "declined"
    end

    def organizer?
      role == "organizer"
    end

    private

    def send_invitation
      # This will be implemented with mailers
      self.invited_at = Time.current
      save
    end

    def handle_status_change
      case status
      when "confirmed"
        event.increment!(:current_attendees)
      when "declined", "cancelled"
        event.decrement!(:current_attendees) if status_before_last_save == "confirmed"
      end
    end
  end
end
