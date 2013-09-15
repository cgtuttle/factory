class Membership < ActiveRecord::Base
  belongs_to :tenant
  belongs_to :user
  accepts_nested_attributes_for :user
  attr_accessible :tenant_id, :user_id, :role

  ROLES = %w[root owner admin manager user]


end
