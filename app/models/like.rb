class Like < ActiveRecord::Base
  belongs_to :entry
  belongs_to :user
  belongs_to :theme
  belongs_to :activity

  default_scope -> { order('updated_at DESC') }

  scope :liked_user, ->(user, entry) { where(entry_id: entry, user_id: user) }

  def self.like!(entry, status, user)
    if status == "remove"
      like = Like.where(entry_id: entry.id, user_id: user)
      like.delete_all
    else
      like =  Like.new
      like.entry_id = entry.id
      like.user_id = entry.user_id
      like.theme_id = entry.theme_id
      like.save
    end

  end

  def self.remove_like!
  end

end
