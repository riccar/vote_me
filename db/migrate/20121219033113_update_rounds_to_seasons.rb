class UpdateRoundsToSeasons < ActiveRecord::Migration
  def change
    rename_column :seasons, :round, :total_round1
    add_column :seasons, :total_round2, :integer, default: 0
    add_column :seasons, :curr_round, :integer, default: 1

   	Season.create :year => 2012, :description => "First Season", 
   							:total_round1 => 10, :total_round2 => 5, :curr_round => 1, 
   							:current => true
  end
end
