class Theme < ActiveRecord::Base
  has_many :entries, dependent: :destroy
  has_many :activity, dependent: :destroy # けす？
  belongs_to :admin, class_name: 'User'

  default_scope -> { order('updated_at DESC') }
  scope :others, ->(id) { where.not(id: id).limit(5) }
end
