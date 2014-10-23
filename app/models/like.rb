class Like < ActiveRecord::Base
  belongs_to :entry
  belongs_to :user
  belongs_to :theme
  belongs_to :activity

  default_scope -> { order('updated_at DESC') }

  def self.like!(entry)
    like =  Like.new
    like.entry_id = entry.id
    like.user_id = entry.user_id
    like.theme_id = entry.theme_id
    like.save
  end

  def self.remove_like!
  end

end
