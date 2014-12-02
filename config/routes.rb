# -*- encoding : utf-8 -*-
ControleDePresencaMagnus::Application.routes.draw do

  get "quadro_de_interesses_nos_horarios/index"

  get "interesse_no_horario/index"

  get "interesse_no_horario/show"

  get "interesse_no_horario/edit"

  devise_for :users
  devise_for :users, :path => "auth", :path_names => { :sign_in => 'login', :sign_out => 'logout', :password => 'secret', :confirmation => 'verification', :unlock => 'unblock', :registration => 'register', :sign_up => 'cmon_let_me_in' }
  devise_scope :user do
    get "sign_in", :to => "devise/sessions#new"
  end
  match "/historico_contatos", to: "pessoas#historico_contatos"

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
  resources :relatorios do as_routes end
  resources :pessoas do
    resources :contatos
  end

  match "/relatorios/visualizar/:id", to: "relatorios#visualizar"

  match "/agenda_do_dia", to: "agenda_do_dia#agenda"

  match "/graficos", to: "graficos#index"

  match "/quadro_de_horarios", to: "quadro_de_horarios#index"

  match "/clientes_inativos", to: "clientes_inativos#index"

  match "/clientes_que_perdemos", to: "clientes_que_perdemos#index"

  match "/clientes_que_ganhamos_e_perdemos", to: "clientes_ganhamos_e_perdemos#index"

  match "/agenda_do_diaresources :products d", to: "agenda_do_dia#agenda"

  match "/registro_presenca", to: "registro_presenca#index"

  match "/gerar_codigo_de_acesso", to: "pessoas#gerar_codigo_de_acesso"

  match "/gerar_bkp", to: "bkp#gerar"

  match "/justificar_falta", to: "pessoas#justificar_falta"

  match "/adiantar_aula", to: "pessoas#adiantar_aula"

  match "/gravar_reposicao", to: "pessoas#gravar_reposicao"

  match "/gravar_realocacao", to: "pessoas#gravar_realocacao"

  match "/aniversariantes", to: "aniversariantes_do_mes#aniversariantes"

  match "/verifica_ultima_pagina_acessada", to: "presencas#verifica_ultima_pagina_acessada"

  match "/registros_de_ponto_por_mes", to: "pessoas#registros_de_ponto_por_mes"

  match "/clientes_inativos_filtrar", to: "clientes_inativos#filtrar"

  match "/get_codigo_do_bairro", to: "pessoas#get_codigo_do_bairro"

  match "/get_codigo_da_cidade", to: "pessoas#get_codigo_da_cidade"

  match "/lista_de_alunos_ativos_inativos", to: "lista_de_alunos_ativos_inativos#ativos_inativos"

  match "/alunos_com_matriculas_canceladas", to: "alunos_com_matriculas_canceladas#matriculas_canceladas"

  match "/presencas_com_matriculas_canceladas/:pessoa_id", to: "alunos_com_matriculas_canceladas#presenca_alunos_matriculas_canceladas"

  get "/agenda_do_dia/filtrar"

  get "/clientes_inativos/filtrar"

  get "/aniversariantes_do_mes/filtrar"

  post "registro_presenca/registrar"

  post "registro_presenca/registro_android"

  post "registro_presenca/registrar_ponto_android"

  get "dados_do_aluno/show"

  get "dados_do_aluno/index"

  post "/registro_presenca/marcar_falta"

  get "/registro_presenca/marcar_falta"

  get "/users/reset_password"

  get "/users/reset_password_edit"

  match "/alunos_xml", to: "pessoas#alunos_xml"

  match "/autocomplete_bairro_nome", to: "cidades#autocomplete_bairro_nome"

  #resource :cidades do
  #  get :autocomplete_bairro_nome, :on => :collection
  #end

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
