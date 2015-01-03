class ThemesController < ApplicationController
  add_template_helper(ApplicationHelper)
  before_action :set_theme, only: %i(show, point_graph)
  before_action :authenticate_user!, only: %i(create, new)
  load_and_authorize_resource

  include Bm25

  def index
    @themes = Theme.all
  end

  def show
    @entry = Entry.new
    @entries = Entry.all.includes(:user).includes(:issues).in_theme(@theme.id).root.page(params[:page]).per(10)
    # @all_entries = Entry.in_theme(@theme.id)
    # @entry_ranking = @all_entries.sort_by { |e| -e.point }. select {|e| e.point > 0 }

    @search_entry = SearchEntry.new
    @keyword = @theme.keywords.select { |k| k.user_id.nil? }.sort_by { |k| -k.score }. group_by { |k| k.score }
    @facilitator = current_user.role == 'admin' || current_user.role == 'facilitator' if user_signed_in?

    @point_history = current_user.point_history(@theme).includes(entry: [:user]).includes(like: [:user]).includes(reply: [:user])
    @point = current_user.point(@theme)

    @activities = current_user.acitivities_in_theme(@theme)

    @other_themes = Theme.others(@theme.id)
    @issue = Issue.new
    @facilitations = Facilitations
    @theme.join!(current_user) if user_join?

    @point_sum = @theme.score(current_user)

    @users = @theme.joins.includes(:user).map(&:user).sort_by { |u| -u.sum_point(@theme) }
    @users_entry = @theme.joins.includes(:user).map(&:user).sort_by { |u| -u.entries.where(theme_id: @theme).count }
    @user_ranking = @theme.point_ranking
    current_user.delete_notice(@theme) if user_signed_in?
  end

  def search_entry
    @entry = Entry.new
    @issue = Issue.new
    @facilitations = Facilitations
    @page = params[:page] || 1

    if params[:search_entry][:order] == 'time'
      @entries = @theme.sort_by_new(params[:search_entry][:issues])
    elsif params[:search_entry][:order] == 'popular'
      @entries = @theme.sort_by_reply(params[:search_entry][:issues])
    elsif params[:search_entry][:order] == 'point'
      @entries = @theme.sort_by_points(params[:search_entry][:issues])
    end

    @entries = Kaminari.paginate_array(@entries).page(params[:page]).per(20)

    respond_to do |format|
      format.js
    end
  end

  def new
    @theme = Theme.new
  end

  def create
    @theme = Theme.new(theme_params)

    respond_to do |format|
      if @theme.save
        format.html { redirect_to @theme, notice: 'テーマを作成しました' }
        format.json { render action: 'show', status: :created, location: @theme }
      else
        format.html { render action: 'new' }
        format.json { render json: @theme.errors, status: :unprocessable_entity }
      end
    end
  end

  def check_new
    notice = Notice.new_notice(current_user, params[:id])
    data = {
      entry: notice.select { |n| n.ntype == 0 },
      reply: notice.select { |n| n.ntype == 1 }.map { |n| { notice: n, entry: n.point_history.entry.body, reply: n.point_history.reply.body } },
      like: notice.select { |n| n.ntype == 2 }.map { |n| { notice: n, entry: n.point_history.entry.body } }
    }
    render json: data.to_json
  end

  def point_graph
    @user = current_user if user_signed_in?
    @points = Point.user_all_point(@user, @theme)
    render 'point_graph', formats: [:json], handlers: [:jbuilder]
  end


  private

  def user_join?
    user_signed_in? && !@theme.join?(current_user) && !current_user.facilitator?
  end

  def set_theme
    @theme = Theme.find(params[:id])
  end

  def theme_params
    params.require(:theme).permit(:title, :body, :color, :admin_id, :image)
  end
end
