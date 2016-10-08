class Webview < ActiveRecord::Base

    belongs_to :user

    def self.count_up(user_id,theme_id)
        params =  {
          user_id: user_id,
          theme_id: theme_id
        }
        Webview.new(params).save
    end

    def self.get_all(theme_id)
        Webview.where(theme_id: theme_id).order("id ASC")
    end

end
