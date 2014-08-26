class Activity < ActiveRecord::Base
  belongs_to :user
  belongs_to :entry
  belongs_to :theme

  # default_scope -> { order('created_at DESC') }

  scope :user,  ->(id) { where(user_id: id) }

  CONTENT = %w(投稿しました。 返信しました。).freeze

  def self.type(entry)
    CONTENT[entry.parent_id.nil? ? 0 : 1]
  end
end
