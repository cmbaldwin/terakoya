class UpdateProjectsForPartners < ActiveRecord::Migration[8.0]
  def change
    # Remove old student reference if it exists
    if column_exists?(:terakoya_projects, :student_id)
      remove_foreign_key :terakoya_projects, :terakoya_students if foreign_key_exists?(:terakoya_projects, :terakoya_students)
      remove_column :terakoya_projects, :student_id
    end

    # Add polymorphic owner reference (can be Partner or Leader)
    add_reference :terakoya_projects, :owner, polymorphic: true, null: false, index: true

    # Add class association
    add_reference :terakoya_projects, :terakoya_class, foreign_key: true

    # Add additional helpful fields
    add_column :terakoya_projects, :visibility, :string, default: "private", null: false
    add_column :terakoya_projects, :tags, :string, array: true, default: []

    add_index :terakoya_projects, :visibility
    add_index :terakoya_projects, :tags, using: :gin
  end
end
