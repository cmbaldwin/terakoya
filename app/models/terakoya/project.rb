module Terakoya
  class Project < ApplicationRecord
    # Associations
    belongs_to :student

    has_many :messages, dependent: :destroy
    has_many :notes, dependent: :destroy
    has_many :todos, dependent: :destroy
    has_many :reminders, dependent: :destroy
    has_many :resources, dependent: :destroy

    # Validations
    validates :title, presence: true
    validates :status, inclusion: { in: %w[planning active paused completed archived] }

    # Scopes
    scope :planning, -> { where(status: "planning") }
    scope :active, -> { where(status: "active") }
    scope :completed, -> { where(status: "completed") }
    scope :recent, -> { order(updated_at: :desc) }

    # State transitions
    def start!
      update!(status: "active", started_at: Time.current)
    end

    def pause!
      update!(status: "paused")
    end

    def resume!
      update!(status: "active")
    end

    def complete!
      update!(status: "completed", completed_at: Time.current)
    end

    def archive!
      update!(status: "archived")
    end

    # Helper methods
    def in_progress?
      status.in?(%w[planning active paused])
    end

    def duration
      return nil unless started_at

      end_time = completed_at || Time.current
      ((end_time - started_at) / 1.day).round
    end

    def progress_percentage
      return 0 if todos.count.zero?

      completed_count = todos.where(status: "completed").count
      (completed_count.to_f / todos.count * 100).round
    end
  end
end
