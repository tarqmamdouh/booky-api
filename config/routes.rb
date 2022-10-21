Rails.application.routes.draw do
  mount_devise_token_auth_for 'User', at: 'auth'

  # sessions
  get 'sessions/alive'

  # booking
  resources :bookings, except: [:destroy, :update]
  get 'mybookings', to: 'bookings#mybookings'
end
