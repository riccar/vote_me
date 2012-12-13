# == Schema Information
#
# Table name: microposts
#
#  id         :integer          not null, primary key
#  content    :string(255)
#  user_id    :integer
#  votes      :integer          default(0)
#  created_at :datetime         not null
#  updated_at :datetime         not null
#

class Micropost < ActiveRecord::Base
  attr_accessible :content, :votes
  belongs_to :user

  validates :user_id, presence: true
  validates :content, presence: true

  default_scope order: 'microposts.created_at DESC'
end
