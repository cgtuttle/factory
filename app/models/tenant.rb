class Tenant < ActiveRecord::Base
	has_many :memberships, :dependent => :destroy
	has_many :users, :through => :memberships
  has_many :roles, :through => :memberships
	accepts_nested_attributes_for :memberships, :users, :roles
  attr_accessible :name

  def self.current_id=(id)
  	logger.debug "running (set) self.current_id: current_id = #{id}"
	  Thread.current[:tenant_id] = id
  end
  
  def self.current_id
  	logger.debug "running (get) self.current_id: current_id = #{Thread.current[:tenant_id]}"
    Thread.current[:tenant_id]
  end 

  def self.factory_sync_id
    Tenant.find_by_name("Factory Sync").id
  end


end
