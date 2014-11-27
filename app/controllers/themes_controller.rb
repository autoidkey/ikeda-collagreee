class ThemesController < ApplicationController
  before_action :set_theme, only: %i(show)
  before_action :authenticate_user!, only: %i(create, new)
  load_and_authorize_resource

  include Bm25

  def index
    @themes = Theme.all
  end

  def show
    @entry = Entry.new
    @entries = Entry.in_theme(@theme.id).root.page(params[:page]).per(20)
    @all_entries = Entry.in_theme(@theme.id)
    @search_entry = SearchEntry.new
    @bm25 = bm25_calc(@all_entries)
    @facilitator = current_user.role == 'admin' || current_user.role == 'facilitator' if user_signed_in?

    @other_themes = Theme.others(@theme.id)
    @issue = Issue.new
    @facilitations = Facilitations
    @theme.join!(current_user) if user_join?

    current_user.delete_notice(@theme)
  end

  def search_entry
    @entry = Entry.new
    @issue = Issue.new
    @facilitations = Facilitations

    # @search_entry = SearchEntry.new(params[:search_entry]) if params[:search_entry].present?
    @page = params[:page] || 1

    if params[:search_entry][:order] == 'time'
      @entries = @theme.newer_entries(params[:search_entry][:issues])
    elsif params[:search_entry][:order] == 'popular'
      @entries = @theme.popular_entries(params[:search_entry][:issues])
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

  def bm25_calc(entries)
    calculate(entries)
  end

  def check_new
    data = { notice: Notice.new_notice(current_user, params[:id]) }
    render json: data.to_json
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
