module Terakoya
  class Leader < ApplicationRecord
    # Associations
    belongs_to :user, polymorphic: true
    has_one :calendar, as: :owner, class_name: "Terakoya::Calendar", dependent: :destroy
    has_many :classes, class_name: "Terakoya::Class", dependent: :destroy
    has_many :class_memberships, through: :classes
    has_many :partners, through: :class_memberships
    has_many :projects, as: :owner, class_name: "Terakoya::Project"
    has_many :notes, as: :author, class_name: "Terakoya::Note"
    has_many :created_events, as: :creator, class_name: "Terakoya::Event"

    # Validations
    validates :display_name, presence: true
    validates :timezone, presence: true
    validates :preferred_language, presence: true, inclusion: { in: %w[en ja both] }
    validates :status, presence: true, inclusion: { in: %w[active inactive archived] }
    validates :user_type, presence: true
    validates :user_id, presence: true, uniqueness: { scope: :user_type }

    # Scopes
    scope :active, -> { where(status: "active") }
    scope :accepting_partners, -> { where(accepting_partners: true, status: "active") }
    scope :by_language, ->(lang) { where("preferred_language = ? OR preferred_language = 'both'", lang) }

    # Callbacks
    after_create :create_default_calendar

    # Instance methods
    def active?
      status == "active"
    end

    def can_accept_partners?
      accepting_partners && (max_partners.nil? || current_partners_count < max_partners)
    end

    def current_partners_count
      class_memberships.active.count
    end

    def upcoming_events
      calendar&.events&.upcoming || Terakoya::Event.none
    end

    def pending_approvals
      calendar&.events&.pending_approval || Terakoya::Event.none
    end

    private

    def create_default_calendar
      self.create_calendar!(
        calendar_type: "leader",
        name: "#{display_name}'s Calendar",
        timezone: timezone
      ) unless calendar.present?
    end
  end
end
