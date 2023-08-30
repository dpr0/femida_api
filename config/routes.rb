# frozen_string_literal: true

Rails.application.routes.draw do
  mount LetterOpenerWeb::Engine, at: "/letter_opener" if Rails.env.development?

  apipie
  use_doorkeeper
  devise_for :users, controllers: { omniauth_callbacks: 'callbacks' }

  resources :users
  resources :files

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
          get :whoosh
          get :phone_rates
          get :turbozaim
          get :turbozaim2
          get :turbozaim3
          get :narod
          get :expired_passports
          get :retro
          get :retro2
          get :start_csv
          get :sample1
          get :sample2
          get :sample3
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
