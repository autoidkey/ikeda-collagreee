class FacilitationKeyword < ActiveRecord::Base
	validates :theme_id, presence: true
	validates :word, presence: true
	validates :score, presence: true
	validates :score, numericality: {
		greater_than: 0, less_than: 1
	}
end
