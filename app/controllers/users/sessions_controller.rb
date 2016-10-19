class SessionsController < Devise::SessionsController

  def create
    # セッションを保存したかったけど、できなかった
    # params[:user].merge!(remember_me: 1)
    super
  end

end