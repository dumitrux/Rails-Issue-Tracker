class AddVotesToIssues < ActiveRecord::Migration[6.0]
  def change
    add_column :issues, :num_votes, :integer
  end
end
