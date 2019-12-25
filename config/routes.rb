Rails.application.routes.draw do
  resources :comments
  resources :issues
  
  devise_for :users, controllers: { omniauth_callbacks: 'users/omniauth_callbacks' }
  root 'issues#index'
  
  resources :issues do
    resources :comments
  end
  # For details on the DSL available within this file, see https://guides.rubyonrails.org/routing.html
  
  post '/issues/:id/vote' => "issues#vote", as: :vote
  post '/issues/:id/watch' => "issues#watch", as: :watch
  put '/issues/:id/delete_attachment' => "issues#delete_attachment", as: :delete_attachment
  put '/issues/:id/status' => "issues#update_status", as: :update_status
  delete '/users/sign_out' => "issues#sign_out", as: :sign_out
  
end
