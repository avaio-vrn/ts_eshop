# -*- encoding : utf-8 -*-
App::Application.routes.draw do
  root to: 'base#home', via: :get
  get '/home_index_page' => redirect('/')
  get :search, to: 'search#index', as: :search
  get '/novinki(/page/:page)', to: 'base#novinki'
  get :aktsii, to: 'base#aktsii'

  resources :tovars do
    member do
      namespace 'goods' do
        get 'choice_model', to: 'choice_model#show'
      end
      get :copy
      get :new_mass
      post :create_mass
    end
  end

  resources :tovar_models do
    get 'yandex_market_form', on: :member
  end

  resources :tovar_stocks, only: %i[new create]

  resources :sections, only: %i[index show] do
    member do
      get 'page/:page', action: :show
      post 'set_per_page', action: 'set_per_page', as: :set_per_page
      get '(page/:page/)change-view/:view', action: :show, as: :change_view
      get 'change-view/:view', action: :show, as: :change_view
    end
  end

  namespace :admin do
    get 'simple_search', to: 'simple_search#index'

    resources :sections do
      resources :page_sections
    end

    resources :pages

    namespace :goods do
      get 'health_check', to: 'health_check#show', as: :health_check

      get 'goods_errors/:id', to: 'goods_errors#show', as: :goods_errors

      get 'tovar_list', to: 'tovar_list#index', as: :tovar_list
      put 'tovar_list', to: 'tovar_list#update'

      resources 'section_goods_properties', only: [:edit, :create]
    end
  end

  namespace :order do
    resources :quick, only: [:new, :create, :update]
  end

  get '/filters/:section_id', to: 'filters/sections#show', as: :filter_section
  post '/filters/:section_id', to: 'filters/sections#update'

  get 'import_pricelist/new', as: :new_import_pricelist
  post 'import_pricelist/create', as: :import_pricelist

  resources :property_types
  resources :tovars_properties

  namespace :properties do
    resources :types, except: :show
    resources :roots_types, except: :show
    resources :values, except: :show
    resources :types_values, except: :show
  end

  resources :banners
  resources :pages_banners, except: :show

  get 'login', to: 'user_sessions#new', as: :login

  mount AuthenticationUser::Engine => '/', as: :authentication_user
  mount Seo::Engine => '/', as: :seo
  mount TemplateSystem::Engine => '/', as: :template_system

  get ':id', to: 'pages#show', as: :page, constraints: { format: 'html' }
end
