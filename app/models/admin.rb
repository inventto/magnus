# -*- encoding : utf-8 -*-
class Admin < ActiveRecord::Base
  attr_accessible :email, :encrypted_password
  devise :database_authenticatable, :timeoutable
end
