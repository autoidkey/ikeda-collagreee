module Api
  class EntriesController < ApplicationController

    def edit
      render json: Entry.first.parent_id
    end

    def show
      if user_signed_in?
        @entries = Entry.where(["created_at > ? and theme_id = ? and user_id != ?", params[:time], params[:id], current_user.id])
        render json: @entries.count
      end
    end

  end
end