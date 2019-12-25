class AddSystemToComments < ActiveRecord::Migration[6.0]
  def change
    add_column :comments, :system, :boolean
  end
end
