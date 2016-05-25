class ApplicationController < ActionController::Base
  # Prevent CSRF attacks by raising an exception.
  # For APIs, you may want to use :null_session instead.

  protect_from_forgery with: :exception

  before_action :configure_permitted_parameters, if: :devise_controller?

  rescue_from CanCan::AccessDenied do |exception|
    redirect_to root_url, alert: exception.message
  end

  def authenticate_admin_user!
    authenticate_user!
    unless current_user.admin?
      flash[:alert] = 'adminユーザのみ利用可能です'
      redirect_to root_path
    end
  end

  #翻訳関係
  before_action :set_locale

  def set_locale
    I18n.locale = params[:locale] || I18n.default_locale
  end

  # link_toなどのすべてのURLにlocaleパラメータを設定するようにする
  def default_url_options(options = {})
    { locale: I18n.locale }.merge options
  end

  protected

  def configure_permitted_parameters
    %i(name realname gender age home move remind mail_format image).each do |col|
      devise_parameter_sanitizer.for(:account_update) << col
      devise_parameter_sanitizer.for(:sign_up) << col
    end
  end
end
