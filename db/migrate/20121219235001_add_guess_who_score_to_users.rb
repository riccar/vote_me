class AddGuessWhoScoreToUsers < ActiveRecord::Migration
  def change
    add_column :users, :guess_who_score, :integer, default: 0
  end
end
