class Theme < ActiveRecord::Base
  has_many :entries, dependent: :destroy
  belongs_to :admin, class_name: 'User'

  default_scope -> { order('created_at DESC') }
end
