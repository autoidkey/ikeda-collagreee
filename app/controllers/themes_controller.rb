class ThemesController < ApplicationController
  before_action :set_theme, only: %i(show)

  def index
    @themes = Theme.all
  end

  def show
    @entry = Entry.new
    @entries = Entry.in_theme(@theme.id)
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
    params.require(:theme).permit(:title, :body, :color, :admin_id)
  end
end
