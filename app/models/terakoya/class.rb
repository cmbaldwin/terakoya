module Terakoya
  class Class < ApplicationRecord
    self.table_name = "terakoya_classes"

    # Associations
    belongs_to :leader, class_name: "Terakoya::Leader"
    has_many :class_memberships, class_name: "Terakoya::ClassMembership",
             foreign_key: :terakoya_class_id, dependent: :destroy
    has_many :partners, through: :class_memberships
    has_many :events, class_name: "Terakoya::Event", foreign_key: :terakoya_class_id
    has_many :notes, class_name: "Terakoya::Note", foreign_key: :terakoya_class_id
    has_many :projects, class_name: "Terakoya::Project", foreign_key: :terakoya_class_id

    # Validations
    validates :name, presence: true
    validates :slug, presence: true, uniqueness: true
    validates :status, presence: true, inclusion: { in: %w[draft active paused archived] }
    validates :visibility, presence: true, inclusion: { in: %w[public private unlisted] }
    validates :current_members, numericality: { greater_than_or_equal_to: 0 }

    # Callbacks
    before_validation :generate_slug, on: :create

    # Scopes
    scope :active, -> { where(status: "active") }
    scope :public_visible, -> { where(visibility: "public") }
    scope :not_archived, -> { where.not(status: "archived") }
    scope :accepting_members, -> { where(status: "active").where("capacity IS NULL OR current_members < capacity") }

    # Instance methods
    def active?
      status == "active"
    end

    def can_accept_members?
      active? && (capacity.nil? || current_members < capacity)
    end

    def at_capacity?
      capacity.present? && current_members >= capacity
    end

    def add_partner(partner, role: "member")
      return false unless can_accept_members?

      membership = class_memberships.create(
        partner: partner,
        role: role,
        status: "active",
        joined_at: Time.current
      )

      increment!(:current_members) if membership.persisted?
      membership
    end

    def remove_partner(partner)
      membership = class_memberships.find_by(partner: partner)
      return false unless membership

      membership.update(status: "inactive", left_at: Time.current)
      decrement!(:current_members)
      true
    end

    def active_partners
      partners.joins(:class_memberships)
              .where(terakoya_class_memberships: { status: "active" })
    end

    def upcoming_events
      events.upcoming
    end

    def calendar
      leader.calendar
    end

    private

    def generate_slug
      return if slug.present?

      base_slug = name.parameterize
      candidate_slug = base_slug
      counter = 1

      while self.class.exists?(slug: candidate_slug)
        candidate_slug = "#{base_slug}-#{counter}"
        counter += 1
      end

      self.slug = candidate_slug
    end
  end
end
