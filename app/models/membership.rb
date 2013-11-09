class Membership < ActiveRecord::Base
  belongs_to :tenant
  belongs_to :user
  belongs_to :role
  accepts_nested_attributes_for :user, :role
  attr_accessible :tenant_id, :user_id, :role_id

  
end
