class Question < ActiveRecord::Base
	validates :live,:city_name_1,:city_reason_1,:city_name_2,:city_reason_2,:city_name_3,:city_reason_3,:city_name_4,:city_reason_4,:city_name_5, :city_reason_5, :city_name_6, :city_reason_6, :q1, :q2, :q3_1, :q3_2, :c1, :c2, :c3, :c4, :c5, :c6, :c7, :c8, :c9, presence: true
end
