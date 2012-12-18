class CreateSeasons < ActiveRecord::Migration
  def change
    create_table :seasons do |t|
      t.integer :year
      t.string :description
      t.integer :round
      t.boolean :current

      t.timestamps
    end
  end
end
