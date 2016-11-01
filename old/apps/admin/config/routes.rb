# Configure your routes here
# See: http://www.rubydoc.info/gems/hanami-router/#Usage
resources :influencers
resources :sessions, only: [:new, :create]
delete 'sessions', to: 'sessions#destroy', as: :session