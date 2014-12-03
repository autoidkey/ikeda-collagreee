class Theme < ActiveRecord::Base
  has_many :entries, dependent: :destroy
  has_many :activities, dependent: :destroy # けす？
  has_many :issues, dependent: :destroy # けす？
  has_many :keywords, dependent: :destroy # けす？
  has_many :users, through: :joins
  has_many :joins
  has_many :likes
  has_many :points
  has_many :point_histories
  belongs_to :admin, class_name: 'User'

  mount_uploader :image, ImageUploader

  default_scope -> { order('updated_at DESC') }
  scope :others, ->(id) { where.not(id: id).limit(5) }

  def popular_entries(issues)
    if issues.present?
      (entries.root.search_issues(issues).sort_by { |e| Entry.children(e.id).count }).reverse
    else
      (entries.root.sort_by { |e| Entry.children(e.id).count }).reverse
    end
  end

  def newer_entries(issues)
    if issues.present?
      entries.root.sort_time.search_issues(issues)
    else
      entries.root.sort_time
    end
  end

  def join!(user)
    users << user
  end

  def join?(user)
    users.include?(user)
  end

  def visible_entries
    entries.where(invisible: false)
  end
end
