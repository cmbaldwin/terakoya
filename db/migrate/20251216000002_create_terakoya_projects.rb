class CreateTerakoyaProjects < ActiveRecord::Migration[8.0]
  def change
    create_table :terakoya_projects do |t|
      t.references :student, null: false, foreign_key: { to_table: :terakoya_students }
      t.string :title, null: false
      t.text :description
      t.text :goal
      t.text :deliverable
      t.string :status, default: "planning", null: false
      t.date :target_date
      t.datetime :started_at
      t.datetime :completed_at
      t.jsonb :metadata, default: {}

      t.timestamps
    end

    add_index :terakoya_projects, :status
    add_index :terakoya_projects, :started_at
    add_index :terakoya_projects, :completed_at
  end
end
