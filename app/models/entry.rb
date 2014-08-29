class Entry < ActiveRecord::Base
  mount_uploader :image, ImageUploader

  belongs_to :user
  belongs_to :theme , touch: true
  has_many :issues, through: :tagged_entries
  has_many :tagged_entries

  default_scope -> { order('updated_at DESC') }
  scope :in_theme, ->(theme) { where(theme_id: theme) }
  scope :children, ->(parent_id) { where(parent_id: parent_id) }
  scope :root, -> { where(parent_id: nil) }

  after_save :logging_activity
  after_save :update_parent_entry_time, unless: :parent?

  def root_entry
    parent_id.nil? ? self : Entry.find(parent_id)
  end

  def root_user
    root_entry.user
  end

  def thread_entries
    Entry.children(root_entry.id)
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

  def tagging!(tag)
    issues << tag
  end

  def update_parent_entry_time
    root_entry.touch
  end
end
