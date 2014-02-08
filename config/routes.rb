Factory::Application.routes.draw do

  devise_for :users, :skip => [:registrations, :sessions], :controllers => {:invitations => 'users/invitations', :registrations => 'users/registrations'}
  
  get "pages/enter"

  as :user do
    get "/login" => "devise/sessions#new", :as => :new_user_session
    post "/login" => "devise/sessions#create", :as => :user_session
    get "/logout" => "devise/sessions#destroy", :as => :destroy_user_session
    get "signup" => "devise/registrations#new", :as => :new_user_registration
    # put "update-registration" => "devise/registrations#update", :as => :user_registration
    # delete "delete-registration" => "devise/registrations#destroy", :as => :delete_user_registration
    # get "edit-registration" => "devise/registrations#edit", :as => :edit_user_registration
    # get "cancel-registration" => "devise/registrations#cancel", :as => :cancel_user_registration
    # post "create-registration" => "devise/registrations#create", :as => :user_registration
    put "update-registration" => "users/registrations#update", :as => :user_registration
    delete "delete-registration" => "users/registrations#destroy", :as => :delete_user_registration
    get "edit-registration" => "users/registrations#edit", :as => :edit_user_registration
    get "cancel-registration" => "users/registrations#cancel", :as => :cancel_user_registration      
  end

  match 'users/:id' => 'users#destroy', :via => :delete, :as => :delete_user
	
	resources :users
  resources :imports
  resources :analyses
  resources :memberships


  resources :categories do
    collection { post :sort}
  end

  resources :traits do
    collection { post :sort}
  end

  resources :items do
    resources :item_specs
  end

  resources :item_specs do
    get 'display', :on => :collection
  end
  
  resources :tenants do
    get 'count', :on => :collection
    get 'set', :on => :member
  end

  match 'item_specs/:id/cancel' => 'item_specs#cancel', :as => :cancel_item_spec
  match 'item_specs/:id/copy' => 'item_specs#copy', :as => :copy_item_spec
  match 'item_specs/:id/notes' => 'item_specs#notes', :as => :notes
  match 'items/:id/copy' => 'items#copy', :as => :copy_item
  match 'analyses/:id/instructions' => 'analyses#instructions'
  match 'imports/help' => 'imports#help', :as => :import_help

  root :to => 'pages#enter'
  
end
