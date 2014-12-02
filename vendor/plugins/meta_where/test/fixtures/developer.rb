# -*- encoding : utf-8 -*-
class Developer < ActiveRecord::Base
  belongs_to :company
  has_and_belongs_to_many :projects
  has_many :notes, :as => :notable

  scope :new_dev, where(:name => 'New Developer')
end
