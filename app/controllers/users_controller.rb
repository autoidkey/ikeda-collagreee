class UsersController < ApplicationController
  # point_api
  include Bm25
  def show
    @user = User.find(params[:id])
    myentries = Entry.where(user_id: @user)
    myreplies = myentries.map { |e| e.parent }
    mylikes = Like.where(user_id: @user).map {|like| like.entry }

    text = mylikes + myreplies + myentries

    @bm25 = bm25(text)
  end

  def bm25(entries)
    calculate(entries)
  end

  def delete_notice
    render nothing: true
    current_user.delete_notice(params[:theme_id])
  end
end
