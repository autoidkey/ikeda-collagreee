class EntriesController < ApplicationController
   before_action :authenticate_user!
   load_and_authorize_resource

   include Np

   def create
     @entry = Entry.new(entry_params)
     @entry_new = Entry.new

     @theme = Theme.find(entry_params[:theme_id])
     @facilitations = Facilitations
     @count = @theme.entries.root.count
   end

   def render_new
     @entry = Entry.find(params[:id])
     @entry_new = Entry.new

     @theme = Theme.find(params[:theme_id])
     @facilitations = Facilitations

     respond_to do |format|
       format.js
     end
   end

   def like
     entry = Entry.find(params[:id])
     @status = params[:status]
     @theme = entry.theme
     if @status == 'remove'
       current_user.unlike! entry
     else
       current_user.like! entry
     end
     respond_to do |format|
       format.js
     end
   end

   def np
     data = { np: calc_np(params[:text]), entry_id: params[:entry_id] }
     respond_to do |format|
       format.json { render json: data.to_json }
     end
   end

   def calc_np(text)
     calculate(text)
   end

   private

   def entry_params
     params.require(:entry).permit(:title, :body, :user_id, :parent_id, :np, :theme_id, :image, :facilitation)
   end
 end