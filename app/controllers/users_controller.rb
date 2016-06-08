class UsersController < ApplicationController
  # point_api
  include Bm25

  def index
    if current_user.admin?
      @q = User.where.not(role: 0).ransack(params[:q])
      @users = @q.result
      @user = User.new
    elsif current_user.organizer?
      @q = User.where.not(role: [0, 3]).ransack(params[:q])
      @users = @q.result
      @user = User.new
    else
      render file: "#{Rails.root}/public/404.html"
    end
  end

  def show
    @user = User.find(params[:id])
    @keyword = @user.keywords.group_by(&:theme_id)
    @entries = @user.entries
    @data = [
      [t('controllers.post'), @entries.root.count],
      [t('controllers.reply'), @entries.where.not(parent_id: nil).count],
      [t('controllers.approve'), @user.likes.status_on.count]
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
