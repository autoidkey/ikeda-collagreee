class UsersController < ApplicationController
  # point_api
  include Bm25

  def index
    @users = User.all
    @q = User.ransack(params[:q])
    @users = @q.result
    @user = User.new
  end

  def show
    @user = User.find(params[:id])
    @keyword = @user.keywords.group_by(&:theme_id)
    @entries = @user.entries
    @data = [
      ['投稿', @entries.root.count],
      ['返信', @entries.where.not(parent_id: nil).count],
      ['賛同', @user.likes.status_on.count]
    ]
  end

  # idとroleの値の組を送る
  def update
    params[:users].each do |(id, value)|
      if value[:check] then
        User.find(id).update_attributes(:role => value[:role].to_i)
      end
    end
    redirect_to index
  end

  def bm25(entries)
    calculate(entries)
  end

  def delete_notice
    render nothing: true
    current_user.delete_notice(params[:theme_id])
  end

  def read_reply_notice
    render nothing: true
    current_user.read_reply_notice(params[:theme_id])
  end

  def read_like_notice
    render nothing: true
    current_user.read_like_notice(params[:theme_id])
  end
end
