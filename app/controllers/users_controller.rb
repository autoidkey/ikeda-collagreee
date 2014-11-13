class UsersController < ApplicationController
  # point_api
  def show
    @user = User.find(params[:id])
  end
end
