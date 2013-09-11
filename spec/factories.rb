FactoryGirl.define do

	factory :user do
	  sequence(:email) { |n| "foo#{n}@example.com" }  
	  password "secret"

#	  after(:create) do |u|
#	 		u.tenants << FactoryGirl.create(:tenant)
#	 	end

	end


	factory :tenant do
		sequence(:name) { |n| "tester#{n}"}
	end
end  