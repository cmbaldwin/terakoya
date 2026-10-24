class CreateTerakoyaEventParticipants < ActiveRecord::Migration[8.0]
  def change
    create_table :terakoya_event_participants do |t|
      t.references :event, null: false, foreign_key: { to_table: :terakoya_events }
      t.references :participant, polymorphic: true, null: false

      t.string :role, default: "attendee", null: false
      t.string :status, default: "pending", null: false

      # RSVP tracking
      t.datetime :invited_at
      t.datetime :response_at
      t.datetime :checked_in_at

      # Participant-specific settings
      t.text :note
      t.boolean :reminder_sent, default: false
      t.jsonb :metadata, default: {}

      t.timestamps
    end

    add_index :terakoya_event_participants, [:event_id, :participant_id, :participant_type],
              unique: true,
              name: "index_event_participants_unique"
    add_index :terakoya_event_participants, :status
    add_index :terakoya_event_participants, :role
  end
end
