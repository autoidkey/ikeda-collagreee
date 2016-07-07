Rails.application.routes.draw do

  resources :thread_classes
  resources :facilitation_infomations
  resources :facilitation_keywords

  ActiveAdmin.routes(self)
  devise_for :users, :controllers => {:sessions => 'sessions'}
  # The priority is based upon order of creation: first created -> highest priority.
  # See how all your routes lay out with "rake routes".

  root to: 'themes#index'

  resources :themes
  resources :issues, only: [:create]
  resources :entries, only: [:show, :create]

  post 'entries/np' => 'entries#np'
  post 'entries/render_new/:id' => 'entries#render_new'
  post 'entries/like' => 'entries#like'

  post 'load_test_api' => 'homes#load_test_api'
  post 'destroy_theme_entries' => 'homes#destroy_theme_entries'

  post 'themes/create_entry/:id' => 'themes#create_entry'
  post 'themes/:id' => 'themes#show'
  get 'themes/order/:id' => 'themes#order'
  get 'themes/search_entry/:id' => 'themes#search_entry'
  get 'themes/check_new/:id' => 'themes#check_new'
  get 'themes/:id/point_graph' => 'themes#point_graph'
  get 'themes/:id/user_point_ranking' => 'themes#user_point_ranking'
  get 'themes/:id/json_user_point' => 'themes#json_user_point'
  get 'themes/only_timeline/:id' => 'themes#only_timeline'
  get 'themes/:id/check_new_message_2015_1.json' => 'themes#check_new_message_2015_1'
  get 'themes/:id/discussion_data' => 'themes#discussion_data'
  get 'themes/:id/point_data' => 'themes#point_data'
  post 'themes/render_new/:id' => 'themes#render_new'
  post 'themes/:id/auto_facilitation_test' => 'themes#auto_facilitation_test'
  get 'themes/:id/auto_facilitation_json' => 'themes#auto_facilitation_json'
  get 'themes/tree_data' => 'themes#tree_data'
  post 'themes/:id/update_phase/:phase' => 'themes#update_phase'
  post "themes/tree/change_session_year" => 'themes#change_session_year'
  post "themes/tree/tree_log_get" => 'themes#tree_log_get'
  post "themes/change_secret/:id" => "themes#change_secret" ,as: "themes_change_secret"

  # api
  get 'users' =>  'users#index'
  get 'users/:id' =>  'users#show'
  post 'users/update' => 'users#update'
  post 'users/delete_notice' =>  'users#delete_notice'
  post 'users/read_reply_notice' =>  'users#read_reply_notice'
  post 'users/read_like_notice' =>  'users#read_like_notice'

  # home routes
  get 'homes/collagree'
  get 'homes/admin'
  get 'homes/about'
  get 'homes/statistic'
  get 'homes/agreement'
  get 'homes/privacy'
  get 'homes/project'
  get 'homes/ua_error'

  get 'homes/introduction'
  get 'homes/intro_account'
  get 'homes/intro_discuss'
  get 'homes/intro_display'
  get 'homes/intro_facilitation'

  get 'homes/:id/json_user_entries' => 'homes#json_user_entries'
  get 'homes/:id/auto_facilitation_json' => 'homes#auto_facilitation_json'
  get 'homes/:id/auto_facilitation_post' => 'homes#auto_facilitation_post'
  get 'homes/:id/auto_facilitation_notice' => 'homes#auto_facilitation_notice'

  get 'thread_classes/all/:id' => 'thread_classes#all',as: "thread_classes_all"
  post 'thread_classes/set/:id' => 'thread_classes#set'
  patch 'thread_classes/set/:id' => 'thread_classes#set'
  # Example of regular route:
  #   get 'products/:id' => 'catalog#view'

  # Example of named route that can be invoked with purchase_url(id: product.id)
  #   get 'products/:id/purchase' => 'catalog#purchase', as: :purchase

  # Example resource route (maps HTTP verbs to controller actions automatically):
  #   resources :products

  # Example resource route with options:
  #   resources :products do
  #     member do
  #       get 'short'
  #       post 'toggle'
  #     end
  #
  #     collection do
  #       get 'sold'
  #     end
  #   end

  # Example resource route with sub-resources:
  #   resources :products do
  #     resources :comments, :sales
  #     resource :seller
  #   end

  # Example resource route with more complex sub-resources:
  #   resources :products do
  #     resources :comments
  #     resources :sales do
  #       get 'recent', on: :collection
  #     end
  #   end

  # Example resource route with concerns:
  #   concern :toggleable do
  #     post 'toggle'
  #   end
  #   resources :posts, concerns: :toggleable
  #   resources :photos, concerns: :toggleable

  # Example resource route within a namespace:
  #   namespace :admin do
  #     # Directs /admin/products/* to Admin::ProductsController
  #     # (app/controllers/admin/products_controller.rb)
  #     resources :products
  #   end
end
