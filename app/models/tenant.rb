class Tenant < ActiveRecord::Base
	has_many :memberships, :dependent => :destroy
	has_many :users, :through => :memberships
	accepts_nested_attributes_for :memberships
	accepts_nested_attributes_for :users

  attr_accessible :name

  cattr_accessor :current_id
  	
end
