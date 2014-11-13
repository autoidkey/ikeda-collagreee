class UsersController < ApplicationController
  # point_api
  def show
    @user = User.find(1)
  end
end
