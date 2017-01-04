class VoteEntry < ActiveRecord::Base
	belongs_to :theme
	belongs_to :entry
	belongs_to :user
end
