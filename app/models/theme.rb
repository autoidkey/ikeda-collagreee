class Theme < ActiveRecord::Base
  has_many :entries, dependent: :destroy
  has_many :activity, dependent: :destroy # けす？
  belongs_to :admin, class_name: 'User'
end
