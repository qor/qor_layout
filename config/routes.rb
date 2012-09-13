Rails.application.routes.draw do
  namespace :qor do
    namespace :layout do
      resources :settings do
        get :toggle, :on => :collection
      end
    end
  end
end
