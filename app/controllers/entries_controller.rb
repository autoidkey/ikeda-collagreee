 class EntriesController < ApplicationController
   before_action :authenticate_user!
   load_and_authorize_resource

   def create
     @entry = Entry.new(entry_params)

     respond_to do |format|
       if @entry.save
         tags = Issue.checked(params[:issues])
         @entry.tagging!(Issue.to_object(tags)) unless tags.empty?

         format.html { redirect_to theme_path(@entry.theme), notice: '投稿しました' }
         format.json { render 'show', status: :created, location: @entry }
       else
         format.html { render action: 'new' }
         format.json { render json: @entry.errors, status: :unprocessable_entity }
       end
     end
   end

   private

   def entry_params
     params.require(:entry).permit(:title, :body, :user_id, :parent_id, :np, :theme_id, :image, :facilitation)
   end
 end
