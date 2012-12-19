class UpdateVotesToMicroposts < ActiveRecord::Migration
 def change
    rename_column :microposts, :votes, :votes_round1
    add_column :microposts, :votes_round2, :integer, default: 0
  end
end
