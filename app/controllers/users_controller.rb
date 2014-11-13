class UsersController < ApplicationController
  # point_api
  include Bm25
  def show
    @user = User.find(params[:id])
    likes = Like.where(user_id: @user).map {|like| like.entry }

    @bm25 = bm25(likes)
  end

  def bm25(entries)
    calculate(entries)
  end
end
