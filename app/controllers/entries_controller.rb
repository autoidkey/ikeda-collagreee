 class EntriesController < ApplicationController
   before_action :set_entry, only: %i(show)

   def index
     @entries = Entry.all
   end

   def show
     @new_entry = Entry.new { |obj| obj.parent_id = @entry.id }
     @entries = Entry.where(parent_id: @entry.id)
   end

   def new
     @entry = Entry.new
   end

   def create
     @entry = Entry.new(entry_params)

     respond_to do |format|
       if @entry.save
         @entry.root_post.touch unless @entry.parent?
         format.html { redirect_to theme_path(@entry.theme), notice: '投稿しました' }
         format.json { render 'show', status: :created, location: @entry }
       else
         format.html { render action: 'new' }
         format.json { render json: @entry.errors, status: :unprocessable_entity }
       end
     end
   end

   private

   def set_entry
     @entry = Entry.find(params[:id])
   end

   def entry_params
     params.require(:entry).permit(:title, :body, :user_id, :parent_id, :np, :theme_id)
   end
 end
