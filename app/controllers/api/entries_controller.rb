module Api
  class EntriesController < ApplicationController

    def edit
      @entries = Entry.where(theme_id: params[:id])
      p params[:time]
      render json: @entries.count
    end

    def show
      @entries = Entry.where(theme_id: params[:id])
      @entries = Entry.where("created_at > ? and theme_id = ? and user_id != ?", params[:time], params[:id], current_user.id)
      p params[:time]
      p @entries.count
      render json: @entries.count
    end

  end
end