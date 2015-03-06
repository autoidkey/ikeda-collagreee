class HomesController < ApplicationController
  protect_from_forgery except: :load_test_api

  def collagree
  end

  def about
  end

  def admin
  end

  def statistic
  end

  def introduction
  end

  def intro_display
  end

  def intro_account
  end

  def intro_discuss
  end

  def intro_facilitation
  end

  def privacy
  end

  def agreement
  end

  def project
  end

  def load_test_api
    entry = Entry.new(entry_params)
    entry.save
    render json: entry.to_json
  end

  def destroy_theme_entries
    binding.pry
    theme = Theme.find(params[:theme_id])
    theme.entries.delete_all
    theme.activities.delete_all
    redirect_to '/'
  end

  private

   def entry_params
     params.permit(:title, :body, :user_id, :parent_id, :np, :theme_id, :image, :facilitation)
   end

end
