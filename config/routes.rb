Rails.application.routes.draw do  
  root 'room#index'
  
  get 'responses' => 'responses#index'
  get 'chat_wheel' => 'responses#chat_wheel'
  
  resources :messages, only: [:new, :create]
end