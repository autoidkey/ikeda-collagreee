class Entry < ActiveRecord::Base
  belongs_to :user
  belongs_to :theme , touch: true

  default_scope -> { order('updated_at DESC') }
  scope :in_theme, ->(theme) { where(theme_id: theme) }
  scope :children, ->(parent_id) { where(parent_id: parent_id) }
  scope :root, -> { where(parent_id: nil) }

  after_save :logging_activity

  def root_post
    parent_id.nil? ? self : Entry.find(parent_id)
  end

  def root_user
    root_post.user
  end

  def thread_entries
    Entry.children(root_post.id)
  end

  def thread_posted_user
    thread_entries.map(&:user).uniq
  end

  def logging_activity
    Activity.logging(self)
  end

  def parent?
    parent_id.nil?
  end
end
