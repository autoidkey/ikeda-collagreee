class Activity < ActiveRecord::Base
  belongs_to :user
  belongs_to :entry
  belongs_to :theme

  default_scope order_by(:created_at.desc)

  scope :user,  ->(id) { where(user_id: id) }

  CONTENT = %w(投稿しました。 返信しました。).freeze

end
