class CreateIssues < ActiveRecord::Migration[6.0]
  def change
    create_table :issues do |t|
      t.string :title
      t.string :assignee
      t.string :issueType
      t.string :priority
      t.integer :user_id
      t.string :description

      t.timestamps
    end
    add_index :issues, [:user_id, :created_at]
  end
end
