class ThemesController < ApplicationController
  # before_filter :authenticate_user!,:only => [:index,:new,:create,:show,:destroy]
  load_and_authorize_resource
  before_action :set_theme, only: %i(show)

  def index
    @themes = Theme.all
  end

  def show
    @entry = Entry.new
    @entries = Entry.in_theme(@theme.id).root
    @other_themes = Theme.others(@theme.id)
    @issue = Issue.new
    @facilitations = Facilitations
    @theme.join!(current_user) if user_signed_in? && !@theme.join?(current_user)
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

  private

  def set_theme
    @theme = Theme.find(params[:id])
  end

  def theme_params
    params.require(:theme).permit(:title, :body, :color, :admin_id, :image)
  end
end
