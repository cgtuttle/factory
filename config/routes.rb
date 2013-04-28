Multitenant::Application.routes.draw do

  match  '/home' => 'static_pages#home'
  match  '/company' => 'static_pages#company'
  match  '/tenant' => 'static_pages#tenant'
  match	 '/company/update' => 'static_pages#update'
  match  '/tenants/:id/destroy_membership' => 'tenants#destroy_membership'
  
  devise_for :users, :skip => [:registrations, :sessions]

  as :user do
    get "/login" => "devise/sessions#new", :as => :new_user_session
    post "/login" => "devise/sessions#create", :as => :user_session
    delete "/logout" => "devise/sessions#destroy", :as => :destroy_user_session
    get "signup" => "devise/registrations#new", :as => :new_user_registration
    put "update-registration" => "devise/registrations#update", :as => :update_user_registration
    delete "delete-registration" => "devise/registrations#destroy", :as => :delete_user_registration
    get "edit-registration" => "devise/registrations#edit", :as => :edit_user_registration
    get "cancel-registration" => "devise/registrations#cancel", :as => :cancel_user_registration
    post "create-registration" => "devise/registrations#create", :as => :user_registration
  end
	
	resources :users
  resources :tenants
  resources :memberships

  root :to => 'static_pages#home'
  
end
