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
  has_many :vote_entries

  validates :body, presence: true
  validates :title, presence: true, if: :is_root?

  default_scope -> { order('updated_at DESC') }
  scope :asc, -> { order('created_at ASC') }
  scope :in_theme, ->(theme) { where(theme_id: theme) }
  scope :theme_user_entries, ->(theme) { includes(likes).where(theme_id: theme) }
  scope :children, ->(parent_id) { where(parent_id: parent_id).includes(likes: :user)}
  scope :root, -> { where(parent_id: nil) }
  scope :sort_time, -> { order('updated_at DESC') }
  # scope :popular, -> { sort_by { |e| Entry.children(e.id).count}.reverse }
  scope :search_issues, ->(issues) { select { |e| issues.map{|i| e.tagged_entries.map { |t| t.issue_id.to_s }.include?(i) }.include?(true) } if issues.present? }
  scope :latest, -> { order('created_at DESC') }
  
  # before_create :check_created_at_and_updated_at

  after_save :logging_activity
  # 動的なポイント付与のためにここをコメントアウトしてみる
  # after_save :logging_point
  after_save :update_parent_entry_time, unless: :is_root?
  # after_save :notice_entry, :notice_facilitation, if: :is_root?

  NP_THRESHOLD = 50
  # FACILITATION1 = "投稿が短いですよ！"
  FACILITATOR_ID = 1
  EXPERIMENT_NAME = 'load_test'

  # def check_created_at_and_updated_at
  #   if self.created_at.blank?
  #     logger.info("created_at is null. id = #{self.id}")
  #     self.created_at = Time.now
  #   end 
  #   if self.updated_at.blank?
  #     logger.info("updated_at is null.")
  #     self.updated_at = Time.now
  #   end 
  # end

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
  def self.post_facilitation(parent, theme_id, body)
    params =  {
      body: body,
      theme_id: theme_id,
      parent_id: parent.id,
      user_id: FACILITATOR_ID,
      facilitation: true,
      np: 50,
      created_at: parent.created_at + 1.minutes,
      updated_at: parent.updated_at + 1.minutes
      }
    Entry.new(params).save
  end

  # オートファシリテーション用のファシリテーション投稿
  def self.post_facilitation_keyword(thread_id, theme_id, body)
    params =  {
      body: body,
      theme_id: theme_id,
      parent_id: thread_id,
      user_id: FACILITATOR_ID,
      facilitation: true,
      np: 50,
      created_at: Time.now,
      updated_at: Time.now
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
    Entry.unscoped.order('id ASC').children(root_entry.id).includes(:user).includes(likes: :user)
  end

  def thread_childrens
    Entry.unscoped.order('id ASC').children(id).includes(:user).includes(likes: :user)
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

  def logging_point(additional_point)
    #puts "追加ポイントを受信:#{additional_point}ポイント!!"
    unless facilitation?
      action = self.is_root? ? 0 : 1
      if action == 0 # 0はPost
        PointHistory.pointing_post(self, 0, action, additional_point)
      elsif !parent.mine?(user) # Reply
        PointHistory.pointing_post(self, 0, action, additional_point)
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

  # 動的にメールを送信するメソッドを呼び出す Entryに書く必要はない
  def self.send_notice_delay(method_name)
      NoticeMailer.send("#{method_name}").deliver
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

  # def liked?(user)
  #   Like.liked_user(user, self).present?
  # end

  def liked?(user)
    likes.each do |like|
      if like.user_id == user.id
        return true
      end
    end
    return false
  end

  def like_count
    if likes.loaded?
      likes.to_a.count
    else
      likes.count
    end
  end

  def all_like_count
    sum = 0
    sum = sum + likes.size
    children.each do |entry|
      sum = sum + entry.likes.size
    end
    return sum
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

  def issue?(issue)
    issues.each do |i|
      if i.id == issue.id
        return true
      end
    end
    return false
  end

  def tagging!(tags)
    self.tagged_entries.all.each do |target|
      flag = true
      tags.each do |tag|
        if tag == target
          flag = false
        end
      end

      if flag
        target.destroy
      end
    end

    tags.each do |tag|
      flag = true
      self.tagged_entries.all.each do |target|
        if tag == target
          flag = false
        end
      end

      if flag
        issues << tag
      end
    end
  end

  def update_parent_entry_time
    root_entry.touch
  end


  # Redis
  def scored(score)
    Redis.current.zadd(EXPERIMENT_NAME + ':entry_points', score, id)
  end

  def score
    Redis.current.zscore(EXPERIMENT_NAME + ':entry_points', id).to_f
  end

  def rank
    Redis.current.zrevrank(EXPERIMENT_NAME + ':entry_points', id) + 1
  end

  def self.top_10
    Redis.current.zrevrange(EXPERIMENT_NAME + ':entry_points', 0, 9).map { |id| Entry.find(id) }
  end
end
