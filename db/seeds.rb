# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the rake db:seed (or created alongside the db with db:setup).
#
# Examples:
#
#   cities = City.create([{ name: 'Chicago' }, { name: 'Copenhagen' }])
#   Mayor.create(name: 'Emanuel', city: cities.first)

	Dir[Rails.root.join('app/models/*.rb').to_s].each do |filename|
	  klass = File.basename(filename, '.rb').camelize.constantize
	  next unless klass.ancestors.include?(ActiveRecord::Base)
	  klass.delete_all	
	end

	Role.create(role_name: 'root', display_order: '0', viewable: false)
	Role.create(role_name: 'owner', display_order: '1', viewable: true)
	Tenant.create(name: 'Root')
