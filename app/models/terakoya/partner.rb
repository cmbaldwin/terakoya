module Terakoya
  class Partner < ApplicationRecord
    # Associations
    belongs_to :user, polymorphic: true
    has_one :calendar, as: :owner, class_name: "Terakoya::Calendar", dependent: :destroy
    has_many :class_memberships, class_name: "Terakoya::ClassMembership", dependent: :destroy
    has_many :classes, through: :class_memberships, source: :terakoya_class
    has_many :leaders, through: :classes
    has_many :projects, as: :owner, class_name: "Terakoya::Project"
    has_many :notes, as: :author, class_name: "Terakoya::Note"
    has_many :created_events, as: :creator, class_name: "Terakoya::Event"
    has_many :event_participations, as: :participant, class_name: "Terakoya::EventParticipant"
    has_many :events, through: :event_participations

    # Validations
    validates :display_name, presence: true
    validates :timezone, presence: true
    validates :preferred_language, presence: true, inclusion: { in: %w[en ja both] }
    validates :status, presence: true, inclusion: { in: %w[active inactive archived] }
    validates :user_type, presence: true
    validates :user_id, presence: true, uniqueness: { scope: :user_type }

    # Scopes
    scope :active, -> { where(status: "active") }
    scope :by_language, ->(lang) { where("preferred_language = ? OR preferred_language = 'both'", lang) }

    # Callbacks
    after_create :create_default_calendar

    # Instance methods
    def active?
      status == "active"
    end

    def active_classes
      class_memberships.active.includes(:terakoya_class).map(&:terakoya_class)
    end

    def upcoming_events
      calendar&.events&.upcoming || Terakoya::Event.none
    end

    def pending_bookings
      event_participations.pending.includes(:event)
    end

    def can_join_class?(terakoya_class)
      !classes.include?(terakoya_class) && terakoya_class.can_accept_members?
    end

    private

    def create_default_calendar
      self.create_calendar!(
        calendar_type: "partner",
        name: "#{display_name}'s Calendar",
        timezone: timezone
      ) unless calendar.present?
    end
  end
end
