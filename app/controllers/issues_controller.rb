class IssuesController < ApplicationController
  before_action :authenticate_user!
  load_and_authorize_resource

  def create
    @issue = Issue.new(issue_params)

    respond_to do |format|
      if @issue.save
        format.html { redirect_to theme_path(@issue.theme), notice: t('controllers.create_tag') }
        format.json { render action: 'show', status: :created, location: @issue }
      else
        format.html { render action: 'new' }
        format.json { render json: @issue.errors, status: :unprocessable_entity }
      end
    end
  end

  private

  def issue_params
    params.require(:issue).permit(:theme_id, :name)
  end
end
