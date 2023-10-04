# frozen_string_literal: true
require 'sidekiq/web'

Rails.application.routes.draw do
  mount LetterOpenerWeb::Engine, at: '/letter_opener' if Rails.env.development?
  mount Sidekiq::Web => '/sidekiq'

  apipie
  devise_for :users

  root 'admin#index'

  resources :admin
  resources :sample
  resources :users
  resources :files
  resources :parser do
    post :solar_phone_check
    post :solar_passp_check
    post :inn_check
    post :cards_check
    post :user_check
    post :db_okb_check
    post :okb_check
    post :xxx_check
    post :add_score
    post :start
    get :download
  end

  namespace :api do
    namespace :femida do
      resources :okb, only: :create do
        post :okb_req
      end
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
          get :enrichment # !!
          get :enrichment_xlsx # !!
          get :cards
          get :cards2
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
