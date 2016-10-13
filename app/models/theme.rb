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
  has_many :core_times, dependent: :destroy 
  has_many :vote_entries
  belongs_to :admin, class_name: 'User'

  mount_uploader :image, ImageUploader

  default_scope -> { order('updated_at DESC') }
  scope :others, ->(id) { where.not(id: id).limit(5) }

  THEME_POINT = 'theme.point'
  BEFORE_0130 = 'before_0130'
  AFTER_0130 = 'after_0130'
  EXPERIMENT_NAME = 'load_test'

  def sort_by_reply(issues)
    if issues.present?
      (entries.root.search_issues(issues).sort_by { |e| Entry.children(e.id).count }).reverse
    else
      (entries.root.sort_by { |e| Entry.children(e.id).count }).reverse
    end
  end

  def sort_by_new(issues)
    if issues.present?
      entries.root.sort_time.search_issues(issues)
    else
      entries.root.sort_time
    end
  end

  def sort_by_points(issues)
    if issues.present?
      entries.root.search_issues(issues).sort_by(&:point).reverse
    else
      entries.root.sort_by(&:point).reverse
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

  # Redis

  # def scored(score, user)
  #   Redis.current.zincrby(POINT_SUM + id.to_s, score, user.id)
  # end

  def like_ranking
    ranking = Entry.where(theme_id: id, parent_id: nil).sort {|a, b|
      b.all_like_count <=> a.all_like_count 
    }
    ranking.select { |v| v.all_like_count  > 0 }
  end

  def like_ranking_check
    Entry.where(theme_id: id, parent_id: nil).sort {|a, b|
      b.all_like_count <=> a.all_like_count 
    }
  end

  def vote_ranking
    votes = VoteEntry.where(theme_id: id)
    vote_hash = {}
    votes.group_by { |i| i.entry_id }.each{|key, value|
      p value
      if value.count > 1
        c = 0
        value.each do |v|
          c = c + v.point
        end
        vote_hash[key] = c
      else
        if !value[0].targer
          vote_hash[key] = value[0].point
        end
      end
    }
    Hash[ vote_hash.sort_by{ |_, v| -v } ]
  end

  # def like_ranking_issue
  #   entries = Entry.where(theme_id: id, parent_id: nil).select { |v| v.all_like_count  > 0 }
  #   ranking_entries = entries.sort {|a, b|
  #     b.all_like_count <=> a.all_like_count 
  #   }

  #   ranking_enties.group_by { |entry| entry.issues.each do |issue|
  #       issue.name
  #     end
  #   }

  #   ranking_enties.group_by { |entry| entry.issues.each do |issue|
  #       issue.name
  #     end
  #   }

  # end

  def core_times_check
    core_times = self.core_times.sort_by { |v| v.start_at }
    core_times.group_by { |e| "#{e.start_at  > Time.now}" 
      if e.end_at  < Time.now
        "no"
      elsif e.end_at  > Time.now
        if e.start_at < Time.now
          "now"
        else e.start_at < Time.now
          "yes"
        end
      end   
    }
  end

  def core_times?
    count = 0
    core_times = self.core_times.sort_by { |v| v.start_at }
    core_times.group_by { |e| "#{e.start_at  > Time.now}" 
      if e.end_at  > Time.now
        if e.start_at < Time.now
          return true
        end
      end   
    }
    return false
  end

  def check_phase(user)
    phase = Phase.all.where(:theme_id => id).order(:created_at).reverse_order[0]
    if !user.webviews.order(:created_at).reverse_order[1].nil?
      if user.webviews.order(:created_at).reverse_order[1].created_at < phase.created_at
        return true
      else
        return false
      end
    else
      return true
    end
  end

  def score(user)
    Redis.current.zscore([EXPERIMENT_NAME, THEME_POINT, id.to_s, 'sum'].join(':'), user.id).to_f
  end

  def point_ranking
    Redis.current.zrevrange([EXPERIMENT_NAME, THEME_POINT, id.to_s, 'sum'].join(':'), 0, 19).map { |id| User.find(id) }
  end

  def score_before_0130(user)
    Redis.current.zscore([EXPERIMENT_NAME, THEME_POINT, id.to_s, BEFORE_0130].join(':'), user.id).to_f
  end

  def point_ranking_before_0130
    Redis.current.zrevrange([EXPERIMENT_NAME, THEME_POINT, id.to_s, BEFORE_0130].join(':'), 0, 9).map { |id| User.find(id) }
  end

  def score_after_0130(user)
    Redis.current.zscore([EXPERIMENT_NAME, THEME_POINT, id.to_s, AFTER_0130].join(':'), user.id).to_f
  end

  def point_ranking_after_0130
    Redis.current.zrevrange([EXPERIMENT_NAME, THEME_POINT, id.to_s, AFTER_0130].join(':'), 0, 9).map { |id| User.find(id) }
  end
end
