# encoding: UTF-8
# This file is auto-generated from the current state of the database. Instead
# of editing this file, please use the migrations feature of Active Record to
# incrementally modify your database, and then regenerate this schema definition.
#
# Note that this schema.rb definition is the authoritative source for your
# database schema. If you need to create the application database on another
# system, you should be using db:schema:load, not running all the migrations
# from scratch. The latter is a flawed and unsustainable approach (the more migrations
# you'll amass, the slower it'll run and the greater likelihood for issues).
#
# It's strongly recommended to check this file into your version control system.

ActiveRecord::Schema.define(:version => 20130513185714) do

  create_table "alunos", :force => true do |t|
    t.string   "nome"
    t.string   "foto"
    t.date     "data_nascimento"
    t.string   "sexo"
    t.string   "email"
    t.integer  "endereco_id"
    t.datetime "created_at",       :null => false
    t.datetime "updated_at",       :null => false
    t.string   "cpf"
    t.string   "codigo_de_acesso"
  end

  create_table "bairros", :force => true do |t|
    t.string   "nome"
    t.integer  "cidade_id"
    t.datetime "created_at", :null => false
    t.datetime "updated_at", :null => false
  end

  create_table "cidades", :force => true do |t|
    t.string   "nome"
    t.integer  "estado_id"
    t.datetime "created_at", :null => false
    t.datetime "updated_at", :null => false
  end

  create_table "enderecos", :force => true do |t|
    t.integer  "cidade_id"
    t.integer  "bairro_id"
    t.integer  "logradouro_id"
    t.string   "numero"
    t.string   "complemento"
    t.datetime "created_at",    :null => false
    t.datetime "updated_at",    :null => false
    t.string   "logradouro"
    t.string   "cep"
  end

  create_table "estados", :force => true do |t|
    t.string   "nome"
    t.string   "sigla"
    t.datetime "created_at", :null => false
    t.datetime "updated_at", :null => false
  end

  create_table "feriados", :force => true do |t|
    t.string   "descricao"
    t.boolean  "feriado_fixo"
    t.boolean  "repeticao_anual"
    t.integer  "dia"
    t.integer  "mes"
    t.integer  "ano"
    t.datetime "created_at",      :null => false
    t.datetime "updated_at",      :null => false
  end

  create_table "horarios_de_aula", :force => true do |t|
    t.integer  "matricula_id"
    t.string   "horario"
    t.integer  "dia_da_semana"
    t.datetime "created_at",    :null => false
    t.datetime "updated_at",    :null => false
  end

  create_table "justificativas_de_falta", :force => true do |t|
    t.string   "descricao"
    t.integer  "presenca_id"
    t.datetime "created_at",  :null => false
    t.datetime "updated_at",  :null => false
  end

  create_table "matriculas", :force => true do |t|
    t.integer  "aluno_id"
    t.string   "objetivo"
    t.date     "data_matricula"
    t.date     "data_inicio"
    t.date     "data_fim"
    t.integer  "numero_de_aulas_previstas"
    t.datetime "created_at",                :null => false
    t.datetime "updated_at",                :null => false
  end

  create_table "presencas", :force => true do |t|
    t.integer  "aluno_id"
    t.date     "data"
    t.string   "horario"
    t.boolean  "presenca"
    t.datetime "created_at",      :null => false
    t.datetime "updated_at",      :null => false
    t.boolean  "reposicao"
    t.boolean  "fora_de_horario"
  end

  create_table "telefones", :force => true do |t|
    t.string   "ddd"
    t.string   "numero"
    t.integer  "tipo_telefone_id"
    t.string   "descricao"
    t.string   "ramal"
    t.integer  "aluno_id"
    t.datetime "created_at",       :null => false
    t.datetime "updated_at",       :null => false
  end

  create_table "tipos_telefone", :force => true do |t|
    t.string   "descricao"
    t.datetime "created_at", :null => false
    t.datetime "updated_at", :null => false
  end

  create_table "users", :force => true do |t|
    t.string   "email",                  :default => "", :null => false
    t.string   "encrypted_password",     :default => "", :null => false
    t.string   "reset_password_token"
    t.datetime "reset_password_sent_at"
    t.datetime "remember_created_at"
    t.integer  "sign_in_count",          :default => 0
    t.datetime "current_sign_in_at"
    t.datetime "last_sign_in_at"
    t.string   "current_sign_in_ip"
    t.string   "last_sign_in_ip"
    t.datetime "created_at",                             :null => false
    t.datetime "updated_at",                             :null => false
  end

  add_index "users", ["email"], :name => "index_users_on_email", :unique => true
  add_index "users", ["reset_password_token"], :name => "index_users_on_reset_password_token", :unique => true

end
