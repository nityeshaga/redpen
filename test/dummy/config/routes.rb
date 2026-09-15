Rails.application.routes.draw do
  mount Redpen::Engine, at: "/redpen"

  resource :session, only: %i[ new create destroy ]
  get "pages/:slug", to: "pages#show", as: :page
  get "documents/:slug", to: "documents#show", as: :document
  root to: redirect("/pages/about")
end
