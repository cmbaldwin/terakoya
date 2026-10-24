class CreateTerakoyaNotes < ActiveRecord::Migration[8.0]
  def change
    create_table :terakoya_notes do |t|
      t.references :author, polymorphic: true, null: false
      t.references :notable, polymorphic: true
      t.references :event, foreign_key: { to_table: :terakoya_events }
      t.references :terakoya_class, foreign_key: true

      t.string :title
      t.text :content
      t.string :visibility, default: "private", null: false
      t.string :status, default: "draft", null: false

      # Rich text and attachments handled via Action Text/Active Storage
      t.string :tags, array: true, default: []
      t.jsonb :metadata, default: {}

      t.datetime :published_at
      t.datetime :archived_at

      t.timestamps
    end

    add_index :terakoya_notes, [:notable_type, :notable_id]
    add_index :terakoya_notes, [:author_type, :author_id]
    add_index :terakoya_notes, :event_id
    add_index :terakoya_notes, :terakoya_class_id
    add_index :terakoya_notes, :visibility
    add_index :terakoya_notes, :status
    add_index :terakoya_notes, :tags, using: :gin
  end
end
