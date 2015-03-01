class Entry < ActiveRecord::Base
  mount_uploader :image, ImageUploader

  belongs_to :user
  belongs_to :theme, touch: true
  has_many :issues, through: :tagged_entries
  has_many :tagged_entries
  has_many :likes
  has_many :point_histories, class_name: 'PointHistory', foreign_key: 'entry_id'
  has_many :point_histories_reply, class_name: 'PointHistory', foreign_key: 'reply_id'
  has_many :notices

  validates :body, presence: true
  validates :title, presence: true, if: :is_root?

  default_scope -> { order('updated_at DESC') }
  scope :asc, -> { order('created_at ASC') }
  scope :in_theme, ->(theme) { where(theme_id: theme) }
  scope :children, ->(parent_id) { where(parent_id: parent_id) }
  scope :root, -> { where(parent_id: nil) }
  scope :sort_time, -> { order('updated_at DESC') }
  # scope :popular, -> { sort_by { |e| Entry.children(e.id).count}.reverse }
  scope :search_issues, ->(issues) { select { |e| issues.map{|i| e.tagged_entries.map { |t| t.issue_id.to_s }.include?(i) }.include?(true) } if issues.present? }
  scope :latest, -> { order('created_at DESC') }

  after_save :logging_activity, :logging_point
  after_save :update_parent_entry_time, unless: :is_root?
  after_save :notice_entry, :notice_facilitation, if: :is_root?

  NP_THRESHOLD = 50
  FACILITATION1 = "投稿が短いですよ！"
  FACILITATOR_ID = 1

  # オートファシリテーション用の投稿コピー
  def copy(parent, theme_id)
    new_entry = self.dup
    new_entry.theme_id = theme_id
    new_entry.parent_id = parent.id unless parent.nil?
    new_entry.created_at = created_at
    new_entry.updated_at = updated_at
    new_entry.save
    new_entry
  end

  # オートファシリテーション用のファシリテーション投稿
  def self.post_facilitation(parent, theme_id)
    params =  {
      body: FACILITATION1,
      theme_id: theme_id,
      parent_id: parent.id,
      user_id: FACILITATOR_ID,
      facilitation: true,
      created_at: parent.created_at + 1.minutes,
      updated_at: parent.updated_at + 1.minutes
      }
    Entry.new(params).save
  end

  def parent
    parent_id.nil? ? self : Entry.find(parent_id)
  end

  def children
    Entry.children(self)
  end

  def root_entry
    parent_id.nil? ? self : Entry.find(parent_id)
  end

  def root_user
    root_entry.user
  end

  def thread_entries
    Entry.children(root_entry.id).includes(:user)
  end

  def thread_childrens
    Entry.children(id).includes(:user)
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

  def logging_point
    unless facilitation?
      action = self.is_root? ? 0 : 1
      if action == 0 # 0はPost
        PointHistory.pointing_post(self, 0, action)
      elsif !parent.mine?(user) # Reply
        PointHistory.pointing_post(self, 0, action)
        PointHistory.pointing_replied(self, 1, 3) unless parent.facilitation?
      end
    end
  end

  def notice_entry
    theme.joins.each do |join|
      next if join.user == user
      params = {
        user_id: join.user.id,
        ntype: 0,
        read: false,
        theme_id: theme.id,
        entry_id: id
      }
      notice = Notice.new(params)
      notice.save
    end
  end

  def notice_facilitation
    if facilitation?
      theme.joins.each do |join|
        Entry.delay.sending_facilitation_notice(self, join)
      end
    end
  end

  def self.sending_facilitation_notice(entry, join)
    NoticeMailer.facilitation_notice(entry, join.user).deliver
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

  def facilitation?
    facilitation
  end

  def is_root?
    parent_id.nil?
  end

  def tagging!(tag)
    issues << tag
  end

  def update_parent_entry_time
    root_entry.touch
  end

  # Redis
  def scored(score)
    Redis.current.zadd('entry_points', score, id)
  end

  def score
    Redis.current.zscore('entry_points', id).to_f
  end

  def rank
    Redis.current.zrevrank('entry_points', id) + 1
  end

  def self.top_10
    Redis.current.zrevrange('entry_points', 0, 9).map { |id| Entry.find(id) }
  end
end
