module Terakoya
  class Student < ApplicationRecord
    # Polymorphic association to host app's user model
    belongs_to :user, polymorphic: true

    # Associations
    has_many :projects, dependent: :destroy
    has_many :messages, as: :sender, dependent: :destroy
    has_many :notes, as: :author, dependent: :destroy
    has_many :todos, foreign_key: :created_by_id, class_name: "Terakoya::Todo", dependent: :destroy
    has_many :reminders, foreign_key: :created_by_id, class_name: "Terakoya::Reminder", dependent: :destroy

    # Validations
    validates :display_name, presence: true
    validates :preferred_language, inclusion: { in: %w[en ja both] }
    validates :timezone, presence: true

    # Scopes
    scope :active, -> { joins(:projects).where(projects: { status: "active" }).distinct }

    # Callbacks
    before_validation :set_defaults, on: :create

    def active_projects
      projects.where(status: %w[planning active])
    end

    def completed_projects
      projects.where(status: "completed")
    end

    private

    def set_defaults
      self.preferred_language ||= "en"
      self.timezone ||= "UTC"
    end
  end
end
