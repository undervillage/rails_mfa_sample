require "devise"

Rails.application.routes.draw do
  get "up" => "rails/health#show", as: :rails_health_check

  devise_for :users, controllers: { sessions: "users/sessions", registrations: "users/registrations" }

  devise_scope :user do
    get "/otp/setup", to: "users/registrations#otp_setup", as: :otp_setup
    post "/otp/verify", to: "users/registrations#verify_otp", as: :otp_verify
  end

  root "home#index"
  get "/dashboard", to: "home#dashboard"
end
