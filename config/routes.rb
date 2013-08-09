ControleDePresencaMagnus::Application.routes.draw do

  devise_for :users
  devise_for :users, :path => "auth", :path_names => { :sign_in => 'login', :sign_out => 'logout', :password => 'secret', :confirmation => 'verification', :unlock => 'unblock', :registration => 'register', :sign_up => 'cmon_let_me_in' }
  devise_scope :user do
    get "sign_in", :to => "devise/sessions#new"
  end

  resources :feriados do as_routes end
  resources :bairros do as_routes end
  resources :estados do as_routes end
  resources :cidades do as_routes end
  resources :presencas do as_routes end
  resources :matriculas do as_routes end
  resources :pessoas do as_routes end
  resources :enderecos do as_routes end
  resources :telefones do as_routes end
  resources :justificativas_de_falta do as_routes end
  resources :horarios_de_aula do as_routes end
  resources :tipos_telefone do as_routes end
  resources :registros_de_ponto do as_routes end

  match "/graficos", to: "graficos#index"

  match "/quadro_de_horarios", to: "quadro_de_horarios#index"

  match "/clientes_inativos", to: "clientes_inativos#index"

  match "/clientes_que_perdemos", to: "clientes_que_perdemos#index"

  match "/agenda_do_dia", to: "agenda_do_dia#agenda"

  match "/registro_presenca", to: "registro_presenca#index"

  match "/gerar_codigo_de_acesso", to: "pessoas#gerar_codigo_de_acesso"

  match "/justificar_falta", to: "pessoas#justificar_falta"

  match "/adiantar_aula", to: "pessoas#adiantar_aula"

  match "/gravar_reposicao", to: "pessoas#gravar_reposicao"

  match "/gravar_realocacao", to: "pessoas#gravar_realocacao"

  match "/aniversariantes", to: "aniversariantes_do_mes#aniversariantes"

  match "/verifica_ultima_pagina_acessada", to: "presencas#verifica_ultima_pagina_acessada"

  get "/agenda_do_dia/filtrar"

  get "/aniversariantes_do_mes/filtrar"

  post "registro_presenca/registrar"

  post "registro_presenca/registro_android"

  post "registro_presenca/registrar_ponto_android"

  post "/registro_presenca/marcar_falta"

  get "/registro_presenca/marcar_falta"

  get "/users/reset_password"

  get "/users/reset_password_edit"

  resource :users do
    post 'do_reset_password'
  end

  # The priority is based upon order of creation:
  # first created -> highest priority.

  # Sample of regular route:
  #   match 'products/:id' => 'catalog#view'
  # Keep in mind you can assign values other than :controller and :action

  # Sample of named route:
  #   match 'products/:id/purchase' => 'catalog#purchase', :as => :purchase
  # This route can be invoked with purchase_url(:id => product.id)

  # Sample resource route (maps HTTP verbs to controller actions automatically):
  #   resources :products

  # Sample resource route with options:
  #   resources :products do
  #     member do
  #       get 'short'
  #       post 'toggle'
  #     end
  #
  #     collection do
  #       get 'sold'
  #     end
  #   end

  # Sample resource route with sub-resources:
  #   resources :products do
  #     resources :comments, :sales
  #     resource :seller
  #   end

  # Sample resource route with more complex sub-resources
  #   resources :products do
  #     resources :comments
  #     resources :sales do
  #       get 'recent', :on => :collection
  #     end
  #   end

  # Sample resource route within a namespace:
  #   namespace :admin do
  #     # Directs /admin/products/* to Admin::ProductsController
  #     # (app/controllers/admin/products_controller.rb)
  #     resources :products
  #   end

  # You can have the root of your site routed with "root"
  # just remember to delete public/index.html.
  root :to => 'agenda_do_dia#agenda'

  # See how all your routes lay out with "rake routes"

  # This is a legacy wild controller route that's not recommended for RESTful applications.
  # Note: This route will make all actions in every controller accessible via GET requests.
  # match ':controller(/:action(/:id))(.:format)'
end
