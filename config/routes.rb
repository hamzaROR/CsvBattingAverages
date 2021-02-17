Rails.application.routes.draw do
  root 'home#index'
  get'home/index'
  post'home/upload_csv'
end
