class UpdateRoundsToSeasons < ActiveRecord::Migration
  def change
    rename_column :seasons, :round, :total_round1
    add_column :seasons, :total_round2, :integer, default: 0
    add_column :seasons, :curr_round, :integer, default: 1
  end
end
