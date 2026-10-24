class DropStudentsTable < ActiveRecord::Migration[8.0]
  def change
    drop_table :terakoya_students, if_exists: true do |t|
      t.references :user, polymorphic: true, null: false, index: true
      t.string :display_name, null: false
      t.string :preferred_language, default: "en"
      t.text :bio
      t.text :goals
      t.string :timezone, default: "UTC"
      t.jsonb :preferences, default: {}
      t.timestamps
    end
  end
end
