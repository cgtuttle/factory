Factory::Application.routes.draw do

  devise_for :users, :skip => [:registrations, :sessions], :controllers => {:invitations => 'users/invitations', :registrations => 'users/registrations'}
  
  get "pages/enter"
  
  as :user do
    get "/login" => "devise/sessions#new", :as => :new_user_session
    post "/login" => "devise/sessions#create", :as => :user_session
    get "/logout" => "devise/sessions#destroy", :as => :destroy_user_session
    get "signup" => "devise/registrations#new", :as => :new_user_registration
    put "update-registration" => "users/registrations#update", :as => :user_registration
    delete "delete-registration" => "users/registrations#destroy", :as => :delete_user_registration
    get "edit-registration" => "users/registrations#edit", :as => :edit_user_registration
    get "cancel-registration" => "users/registrations#cancel", :as => :cancel_user_registration      
  end

  match 'users/:id' => 'users#destroy', :via => :delete, :as => :delete_user
	
	resources :users
  resources :imports
  resources :memberships

  resources :analyses do   
    post 'bulk_delete', :on => :collection    
  end

  resources :categories do
    collection { post :sort}
    post 'bulk_delete', :on => :collection
  end

  resources :properties do
    collection { post :sort}    
    post 'bulk_delete', :on => :collection
    collection {post :import}    
  end

  resources :items do
    post 'bulk_delete', :on => :collection
    resources :specifications
    collection {post :import}
  end

  resources :specifications do
    get 'display', :on => :collection
    get 'new_import', :on => :collection
    collection {post :save_import}
  end
  
  resources :tenants do
    get 'count', :on => :collection
    get 'set', :on => :member
  end

  resources :imports do
    collection {get :import}
  end

  match 'specifications/:id/cancel' => 'specifications#cancel', :as => :cancel_specification
  match 'specifications/:id/copy' => 'specifications#copy', :as => :copy_specification
  match 'specifications/:id/paste' => 'specifications#paste', :as => :paste_specification
  match 'specifications/:id/notes' => 'specifications#notes', :as => :notes
  match 'items/:id/copy' => 'items#copy', :as => :copy_item
  match 'analyses/:id/instructions' => 'analyses#instructions'
  match 'imports/help' => 'imports#help', :as => :import_help
  match 'about' => 'pages#about', :as => :about

  root :to => 'pages#enter'
  
end
