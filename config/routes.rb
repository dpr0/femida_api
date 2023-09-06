# frozen_string_literal: true

Rails.application.routes.draw do
  mount LetterOpenerWeb::Engine, at: '/letter_opener' if Rails.env.development?

  apipie
  devise_for :users

  resources :users
  resources :files
  resources :parser do
    post :parse
    post :solar_check
    post :inn_check
    post :user_check
    post :okb_check
    get :get_csv
    get :sample, on: :collection
  end

  namespace :api do
    namespace :femida do
      resources :okb,     only: :create
      resources :debtors, only: :show
      resources :fsin,    only: :show
      resources :egrul,   only: :show
      resources :arbitr,  only: :show
      resources :npd,     only: :show
      resources :bankrot, only: :show
      resources :nalog,   only: :show do
        collection do
          get :ogr
          get :uchr
          get :ip
          get :rdl
        end
      end
      resources :inn,     only: [:index, :show]
      resources :opendata,only: [:index, :show]
      resources :driver,  only: :index
      resources :sro,     only: :index
      resources :websbor, only: :index
      resources :bonalog, only: :index
      resources :fedsfm,  only: :index
      resources :users,   only: [:index, :show]
      resources :fssp_wanted, only: :index
      resources :parser do
        collection do
          get :phone_rates
          get :turbozaim
          get :turbozaim2
          get :turbozaim3
          get :narod
        end
      end
      resources :esia, only: :index do
        collection do
          get :passport
          get :phone
          get :email
          get :inn
          get :snils
        end
      end
    end
  end
end
