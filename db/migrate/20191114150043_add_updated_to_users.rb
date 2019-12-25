class AddUpdatedToUsers < ActiveRecord::Migration[6.0]
  def change
    add_column :users, :updated, :string
    add_column :users, :created, :string
  end
end
