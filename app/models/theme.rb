class Theme < ActiveRecord::Base
  has_many :entries, dependent: :destroy
  belongs_to :admin, class_name: 'User'
end
