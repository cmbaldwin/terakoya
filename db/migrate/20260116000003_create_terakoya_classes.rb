class CreateTerakoyaClasses < ActiveRecord::Migration[8.0]
  def change
    create_table :terakoya_classes do |t|
      t.references :leader, null: false, foreign_key: { to_table: :terakoya_leaders }
      t.string :name, null: false
      t.string :description
      t.string :slug, null: false
      t.string :status, default: "active", null: false
      t.integer :capacity
      t.integer :current_members, default: 0, null: false
      t.string :meeting_schedule
      t.string :timezone, default: "UTC"
      t.jsonb :settings, default: {}
      t.string :color, default: "#3788d8"
      t.string :visibility, default: "public", null: false
      t.datetime :starts_at
      t.datetime :ends_at
      t.datetime :archived_at

      t.timestamps
    end

    add_index :terakoya_classes, :slug, unique: true
    add_index :terakoya_classes, :leader_id
    add_index :terakoya_classes, :status
    add_index :terakoya_classes, :visibility
    add_index :terakoya_classes, :archived_at
  end
end
