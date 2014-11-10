class Entry < ActiveRecord::Base
  mount_uploader :image, ImageUploader

  belongs_to :user
  belongs_to :theme, touch: true
  has_many :issues, through: :tagged_entries
  has_many :tagged_entries
  has_many :likes
  has_many :point_histories, :class_name => 'PointHistory', :foreign_key => 'entry_id'
  has_many :point_histories_reply, :class_name => 'PointHistory', :foreign_key => 'reply_id'

  default_scope -> { order('updated_at DESC') }
  scope :in_theme, ->(theme) { where(theme_id: theme) }
  scope :children, ->(parent_id) { where(parent_id: parent_id) }
  scope :root, -> { where(parent_id: nil) }
  scope :sort_time, -> { root.order('updated_at DESC') }
  scope :popular, -> { root.sort_by{|e| Entry.children(e.id).count}.reverse }
  scope :search_issues, ->(issues) {root.select{|e| issues.map{|i| e.tagged_entries.map{|t| t.issue_id.to_s}.include?(i)}.include?(true)} if issues.present?}

  after_save :logging_activity, :adding_point
  after_save :update_parent_entry_time, unless: :is_root?

  NP_THRESHOLD = 50

  def parent
    parent_id.nil? ? self : Entry.find(parent_id)
  end

  def root_entry
    parent_id.nil? ? self : Entry.find(parent_id)
  end

  def root_user
    root_entry.user
  end

  def thread_entries
    Entry.children(root_entry.id)
  end

  def thread_childrens
    Entry.children(id)
  end

  def thread_np_count
    thread_entries.partition(&:positive?)
  end

  def thread_posted_user
    thread_entries.map(&:user).uniq
  end

  def thread_positive_count
    thread_np_count[0].count
  end

  def thread_negative_count
    thread_np_count[1].count
  end

  def logging_activity
    return if facilitation? && user.admin?
    Activity.logging(self)

    # 2は返信
    Activity.logging(root_entry, 2) unless is_root? || root?
    logged = []
    thread_entries.each do |entry|
      next if entry.mine?(user) || entry.root_user? || logged.include?(entry.user)
      logged << entry.user
      Activity.logging(entry, 2)
    end
  end

  def adding_point
    action = self.is_root? ? 0 : 1
    if action == 0 # 0はPost
      PointHistory.pointing_post(self, 0, action)
    elsif !self.parent.mine?(self.user) # Reply
      PointHistory.pointing_post(self, 0, action)
      PointHistory.pointing_replied(self, 1, 3)
    end
  end

  def point
    PointHistory.entry_point(self).present? ? PointHistory.entry_point(self).inject(0) { |sum, history| sum + history.point } : 0
  end

  def mine?(user)
    self.user == user
  end

  def liked?(user)
    Like.liked_user(user, self).present?
  end

  def like_count
    Like.all_likes(self).count
  end

  def positive?
    np >= NP_THRESHOLD
  end

  def root_user?
    user == root_user
  end

  def root?
    user.id == root_entry.user.id
  end

  def grandchild?
    parent_id.present? ? Entry.find(parent_id).parent_id.present? : false
  end

  # change to 'is_root?'
  # def parent?
  #   parent_id.nil?
  # end

  def is_root?
    parent_id.nil?
  end

  def tagging!(tag)
    issues << tag
  end

  def update_parent_entry_time
    root_entry.touch
  end
end
