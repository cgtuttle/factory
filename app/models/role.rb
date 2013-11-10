class Role < ActiveRecord::Base
	has_many :memberships
  attr_accessible :role_name, :display_order
  scope :for_list, where(:viewable => true ).order('display_order')


end
