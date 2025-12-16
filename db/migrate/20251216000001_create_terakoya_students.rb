class CreateTerakoyaStudents < ActiveRecord::Migration[8.0]
  def change
    create_table :terakoya_students do |t|
      t.references :user, polymorphic: true, null: false
      t.string :display_name, null: false
      t.string :preferred_language, default: "en", null: false
      t.text :bio
      t.text :goals
      t.string :timezone, default: "UTC", null: false
      t.jsonb :preferences, default: {}

      t.timestamps
    end

    add_index :terakoya_students, [:user_type, :user_id], unique: true
  end
end
