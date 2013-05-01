class Tenant < ActiveRecord::Base
	has_many :memberships, :dependent => :destroy
	has_many :users, :through => :memberships
	accepts_nested_attributes_for :memberships
	accepts_nested_attributes_for :users

  attr_accessible :name

  cattr_accessor :current_id

  def self.current_id=(id)
    Thread.current[:tenant_id] = id
  end
  
  def self.current_id
    Thread.current[:tenant_id]
  end
  	
end
