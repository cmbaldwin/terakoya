class CreateTerakoyaCalendars < ActiveRecord::Migration[8.0]
  def change
    create_table :terakoya_calendars do |t|
      t.references :owner, polymorphic: true, null: false, index: true
      t.string :calendar_type, null: false
      t.string :name
      t.string :timezone, default: "UTC", null: false
      t.string :color, default: "#3788d8"
      t.boolean :is_public, default: false, null: false
      t.jsonb :settings, default: {}
      t.jsonb :work_hours, default: {}
      t.jsonb :booking_rules, default: {}
      t.integer :default_event_duration, default: 60
      t.integer :buffer_time, default: 0
      t.integer :advance_booking_days, default: 30
      t.integer :minimum_notice_hours, default: 24

      t.timestamps
    end

    add_index :terakoya_calendars, [:owner_type, :owner_id, :calendar_type],
              unique: true,
              name: "index_calendars_on_owner_and_type"
    add_index :terakoya_calendars, :calendar_type
    add_index :terakoya_calendars, :is_public
  end
end
