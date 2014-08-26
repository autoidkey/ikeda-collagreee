class EntriesController < ApplicationController
  before_action :set_entry, only: [:show]

  def index
    @entries = Entry.all
  end

  def show
    @entry = Entry.new { |obj| obj.parent_id = @contact.id }
    @entries = Entry.where(parent_id: @contact.id)
  end

  def new
    @entry = Entry.new
  end

  def create
    @entry = Entry.new(entry_params)

    respond_to do |format|
      if @entry.save
        format.html { redirect_to @entry, notice: '投稿しました' }
        format.json { render action: 'show', status: :created, location: @entry }
      else
        format.html { render action: 'new' }
        format.json { render json: @entry.errors, status: :unprocessable_entity }
      end
    end
  end

  private

  def set_entry
    @contact = Entry.find(params[:id])
  end

  def entry_params
    params.require(:entry).permit(:title, :body, :user_id, :parent_id, :np)
  end
end
