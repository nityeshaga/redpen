Redpen::Engine.routes.draw do
  # Notes on a page, and resolving one: create resolves, destroy reopens. No verbs.
  resources :notes, only: %i[ index create destroy ] do
    resource :resolution, only: %i[ create destroy ]
  end
end
