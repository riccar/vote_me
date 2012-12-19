class Season < ActiveRecord::Base
  attr_accessible :current, :description, :year, :total_round1, :total_round2, :curr_round
end
