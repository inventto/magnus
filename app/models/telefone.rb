# -*- encoding : utf-8 -*-
#coding: utf-8
class Telefone < ActiveRecord::Base
  attr_accessible :pessoa_id, :ddd, :descricao, :numero, :ramal, :tipo_telefone_id, :tipo_telefone

  belongs_to :tipo_telefone
  belongs_to :pessoa

  validates_presence_of :ddd, :unless => "numero.blank?"
  validates_presence_of :numero, :unless => "ddd.blank?"
  validates_presence_of :tipo_telefone, :if => "not ddd.blank? and not numero.blank?"
  validates_each :numero do |model, attr, value|
    if not value.blank?
      number = value.gsub(/[\s-]/,"")
      if not (8..9).cover?(number.length)
        model.errors.add(attr, "Inválido")
      end
    end
  end

  def label
    desc = ""
    if not self.ddd.nil? and not self.numero.nil?
      desc = "(" << self.ddd.gsub(/\D/,"") << ") "
      numero = self.numero.gsub(/\D/,"")
      if numero.length == 8
        desc << numero[0..3] << " -  " << numero[4..8]
      elsif numero.length == 9
        desc << numero[0..4] << " -  " << numero[5..9]
      else
        desc << numero
      end
    end
    desc
  end
end
