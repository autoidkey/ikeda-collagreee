module Api
  class EntriesController < ApplicationController

    def edit
      @entries = Entry.where(theme_id: params[:id])
      render json: @entries.count
    end

    def show
      @entries = Entry.where(theme_id: params[:id])
      render json: @entries.count
    end

  end
end