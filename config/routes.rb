Terakoya::Engine.routes.draw do
  root "dashboard#show"

  # Dashboard and mode switching
  get "dashboard", to: "dashboard#show", as: :dashboard
  post "dashboard/switch_mode", to: "dashboard#switch_mode", as: :switch_mode

  # Partner and Leader profiles
  resource :partner, only: [:new, :create, :show, :edit, :update]
  resource :leader, only: [:new, :create, :show, :edit, :update]

  # Classes
  resources :classes, param: :slug, path: "classes", as: :terakoya_classes do
    member do
      post :join
      post :leave
    end
  end

  # Calendars and Events
  resource :calendar, only: [:show, :edit, :update] do
    resources :events, only: [:new, :create]
  end

  resources :events do
    member do
      post :confirm
      post :cancel
    end
  end

  # Notes
  resources :notes

  # Projects
  resources :projects do
    member do
      post :start
      post :pause
      post :resume
      post :complete
    end

    # Project-specific resources (to be implemented in future)
    # resources :messages, only: [:index, :create]
    # resources :todos
    # resources :reminders
    # resources :resources, controller: "project_resources"
  end
end
