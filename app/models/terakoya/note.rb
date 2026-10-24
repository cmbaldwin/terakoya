module Terakoya
  class Note < ApplicationRecord
    # Associations
    belongs_to :author, polymorphic: true
    belongs_to :notable, polymorphic: true, optional: true
    belongs_to :event, class_name: "Terakoya::Event", optional: true
    belongs_to :terakoya_class, class_name: "Terakoya::Class", optional: true

    # For rich text content (Action Text)
    has_rich_text :content

    # For file attachments (Active Storage)
    has_many_attached :attachments

    # Validations
    validates :visibility, presence: true, inclusion: { in: %w[private shared_with_class public] }
    validates :status, presence: true, inclusion: { in: %w[draft published archived] }

    # Scopes
    scope :published, -> { where(status: "published") }
    scope :draft, -> { where(status: "draft") }
    scope :visible_to_public, -> { where(visibility: "public", status: "published") }
    scope :for_class, ->(terakoya_class) { where(terakoya_class: terakoya_class) }
    scope :for_event, ->(event) { where(event: event) }
    scope :recent, -> { order(created_at: :desc) }

    # Instance methods
    def publish!
      update(status: "published", published_at: Time.current)
    end

    def archive!
      update(status: "archived", archived_at: Time.current)
    end

    def visible_to?(user_or_role)
      case visibility
      when "public"
        status == "published"
      when "shared_with_class"
        return false unless terakoya_class
        return true if author == user_or_role
        has_class_access?(user_or_role)
      when "private"
        author == user_or_role
      else
        false
      end
    end

    def editable_by?(user_or_role)
      author == user_or_role
    end

    def published?
      status == "published"
    end

    def draft?
      status == "draft"
    end

    def archived?
      status == "archived"
    end

    private

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
  end
end
