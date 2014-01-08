Crunchinator::Application.routes.draw do
  # single version of the api for now.  More will come later so lets make it an array
  ['v1'].each do |version|
    namespace version.to_sym do
      resources :companies, only: [:index]
      resources :investors, only: [:index]
      resources :categories, only: [:index]
    end
  end
end
