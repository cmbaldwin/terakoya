module Terakoya
  class ClassMembership < ApplicationRecord
    # Associations
    belongs_to :terakoya_class, class_name: "Terakoya::Class"
    belongs_to :partner, class_name: "Terakoya::Partner"

    # Validations
    validates :role, presence: true, inclusion: { in: %w[member co_leader] }
    validates :status, presence: true, inclusion: { in: %w[active inactive pending] }
    validates :partner_id, uniqueness: { scope: :terakoya_class_id }

    # Callbacks
    before_create :set_joined_at

    # Scopes
    scope :active, -> { where(status: "active") }
    scope :inactive, -> { where(status: "inactive") }
    scope :pending, -> { where(status: "pending") }
    scope :members, -> { where(role: "member") }
    scope :co_leaders, -> { where(role: "co_leader") }

    # Instance methods
    def activate!
      update(status: "active", joined_at: Time.current)
    end

    def deactivate!
      update(status: "inactive", left_at: Time.current)
    end

    def active?
      status == "active"
    end

    def duration_days
      return nil unless joined_at

      end_time = left_at || Time.current
      ((end_time - joined_at) / 1.day).round
    end

    private

    def set_joined_at
      self.joined_at ||= Time.current if status == "active"
    end
  end
end
