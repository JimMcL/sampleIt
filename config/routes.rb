Rails.application.routes.draw do
  # For details on the DSL available within this file, see http://guides.rubyonrails.org/routing.html
  # For a list of routes (available in debug environment), see http://localhost/rails/info/routes

  resources :projects
  get 'welcome/index'

  delete 'photo_files/:id', to: 'photo_files#destroy'
  get 'photo_files', to: 'photo_files#index'

  resources :taxa do
    member do
      get 'edit_parent_taxon'
    end
    collection do
      get 'autocomplete'
      post 'cleanup'
    end
  end

  resources :specimens do
    resources :photos
    member do
      get 'edit_site'
      get 'copy'
    end
    collection do
      get 'summary'
      get 'kiosk'
    end
  end

  resources :sites do
    resources :photos
  end

  resources :photos do
    collection do
      get 'summary'
    end
  end

  resources :sites, :specimens, :taxa, :photos

  root 'welcome#index'

end
