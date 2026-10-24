class CreateTerakoyaEvents < ActiveRecord::Migration[8.0]
  def change
    create_table :terakoya_events do |t|
      t.references :calendar, null: false, foreign_key: { to_table: :terakoya_calendars }
      t.references :creator, polymorphic: true, null: false
      t.references :terakoya_class, foreign_key: true

      # Core attributes
      t.string :title, null: false
      t.text :description
      t.string :location
      t.datetime :start_time, null: false
      t.datetime :end_time, null: false
      t.integer :duration_minutes

      # Event configuration
      t.string :event_type, default: "booking", null: false
      t.string :visibility, default: "class_only", null: false
      t.string :status, default: "draft", null: false
      t.integer :capacity
      t.integer :current_attendees, default: 0

      # Visual customization
      t.string :color
      t.string :icon

      # Meeting details
      t.string :meeting_link
      t.string :meeting_provider
      t.text :join_instructions

      # Scheduling rules
      t.integer :buffer_before, default: 0
      t.integer :buffer_after, default: 0
      t.integer :cancellation_deadline_hours
      t.integer :reschedule_limit, default: 3
      t.boolean :requires_approval, default: true

      # Reminders and notifications
      t.integer :reminder_offset_minutes, default: 60
      t.boolean :send_email_notifications, default: true
      t.datetime :reminder_sent_at

      # Recurring events
      t.string :recurring_rule
      t.datetime :recurring_until
      t.references :parent_event, foreign_key: { to_table: :terakoya_events }
      t.boolean :is_template, default: false

      # Monetization (future)
      t.integer :price_cents, default: 0
      t.string :currency, default: "USD"

      # Tracking and analytics
      t.datetime :confirmed_at
      t.datetime :cancelled_at
      t.datetime :completed_at
      t.integer :feedback_rating
      t.text :feedback_text
      t.string :cancellation_reason

      # Flexible metadata
      t.string :tags, array: true, default: []
      t.jsonb :metadata, default: {}

      t.timestamps
    end

    add_index :terakoya_events, :start_time
    add_index :terakoya_events, :end_time
    add_index :terakoya_events, [:calendar_id, :start_time]
    add_index :terakoya_events, :event_type
    add_index :terakoya_events, :visibility
    add_index :terakoya_events, :status
    add_index :terakoya_events, :terakoya_class_id
    add_index :terakoya_events, :parent_event_id
    add_index :terakoya_events, :is_template
    add_index :terakoya_events, :tags, using: :gin
  end
end
