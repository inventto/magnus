# -*- encoding : utf-8 -*-
class Contato < ActiveRecord::Base
  belongs_to :pessoa
  validates_presence_of :data_contato, :descricao, :on => :create
  attr_accessible :data_contato, :descricao, :pessoa_id
  scope :por_id, ->(id) { where(id: id) }
end
