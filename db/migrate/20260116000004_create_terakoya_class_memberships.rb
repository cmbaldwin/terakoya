class CreateTerakoyaClassMemberships < ActiveRecord::Migration[8.0]
  def change
    create_table :terakoya_class_memberships do |t|
      t.references :terakoya_class, null: false, foreign_key: true
      t.references :partner, null: false, foreign_key: { to_table: :terakoya_partners }
      t.string :role, default: "member", null: false
      t.string :status, default: "active", null: false
      t.datetime :joined_at
      t.datetime :left_at
      t.jsonb :metadata, default: {}

      t.timestamps
    end

    add_index :terakoya_class_memberships, [:terakoya_class_id, :partner_id],
              unique: true,
              name: "index_class_memberships_on_class_and_partner"
    add_index :terakoya_class_memberships, :status
    add_index :terakoya_class_memberships, :role
  end
end
