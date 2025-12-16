Terakoya::Engine.routes.draw do
  root "dashboard#show"

  # Student registration and profile
  resource :student, only: [:new, :create, :show, :edit, :update]

  # Dashboard
  get "dashboard", to: "dashboard#show", as: :dashboard

  # Projects
  resources :projects do
    member do
      post :start
      post :pause
      post :resume
      post :complete
    end

    # Project-specific resources (to be implemented in Phase 2+)
    # resources :messages, only: [:index, :create]
    # resources :notes
    # resources :todos
    # resources :reminders
    # resources :resources, controller: "project_resources"
  end
end
