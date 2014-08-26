class Activities < ActiveRecord::Base
  belongs_to :user
  default_scope order_by(:created_at.desc)

  scope :user,  ->(id) { where(user_id: id) }


end
