module Api
  class EntriesController < ApplicationController

    def edit
      @new_entry = Entry.where(["created_at > ? and theme_id = ? and user_id != ?", params[:time], params[:id], current_user.id])
      p @new_entry
      p "aaaa"
      p @new_entry.count

      render json: @new_entry.count
    end

    def show
      @entries = Entry.where(["created_at > ? and theme_id = ? and user_id != ?", params[:time], params[:id], current_user.id])
      render json: @entries.count
    end

  end
end