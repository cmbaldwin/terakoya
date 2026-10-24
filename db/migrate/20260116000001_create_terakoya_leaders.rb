class CreateTerakoyaLeaders < ActiveRecord::Migration[8.0]
  def change
    create_table :terakoya_leaders do |t|
      t.references :user, polymorphic: true, null: false, index: true
      t.string :display_name, null: false
      t.string :bio
      t.string :expertise, array: true, default: []
      t.string :timezone, default: "UTC", null: false
      t.string :preferred_language, default: "en", null: false
      t.jsonb :settings, default: {}
      t.jsonb :availability_rules, default: {}
      t.boolean :accepting_partners, default: true
      t.integer :max_partners
      t.string :status, default: "active", null: false

      t.timestamps
    end

    add_index :terakoya_leaders, [:user_type, :user_id], unique: true
    add_index :terakoya_leaders, :status
    add_index :terakoya_leaders, :accepting_partners
  end
end
