class CreateTerakoyaPartners < ActiveRecord::Migration[8.0]
  def change
    create_table :terakoya_partners do |t|
      t.references :user, polymorphic: true, null: false, index: true
      t.string :display_name, null: false
      t.string :bio
      t.string :goals
      t.string :timezone, default: "UTC", null: false
      t.string :preferred_language, default: "en", null: false
      t.jsonb :settings, default: {}
      t.string :status, default: "active", null: false

      t.timestamps
    end

    add_index :terakoya_partners, [:user_type, :user_id], unique: true
    add_index :terakoya_partners, :status
  end
end
