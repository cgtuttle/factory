require 'spec_helper'

describe "Entry pages" do

	describe "Home page" do
		it "should have the content 'EntryPages#home'" do
      visit '/'
      page.should have_content('EntryPages#home')
    end
  end

  describe "user registration" do
    it "allows the user to register" do
      visit new_user_registration_path
      fill_in "Email", :with => "rspec_user@test.com"
      fill_in "Password", :with => "tester"
      fill_in "Password confirmation", :with => "tester"
      click_button "Sign up"
      page.should have_content('EntryPages#welcome')
    end
  end

  describe "user login link" do
    it "should navigate to the user login page" do
      visit '/'
      click_link('Login')
      page.should have_content('Sign in')
    end
  end

  describe "wrong user login" do
    it "should not successfully login the user" do
      visit '/login'
      click_button "Sign in"
      page.should have_content('Invalid email or password')
    end
  end

  describe "user login" do
    it "should successfully login the user" do
      login
      page.should have_content('EntryPages#welcome')
    end
  end

  describe "create company" do
    it "should successfully allow user to add tenant and show only that tenant's data" do
      @wrong_user = FactoryGirl.create(:user)
      @company = FactoryGirl.create(:tenant)
      login
      click_link "Add a company"
      fill_in "tenant[name]", :with => @company.name
      click_button "Sign up"
      page.should have_content("Welcome to #{@company.name}")
      page.should have_content(@user.email) 
      page.should_not have_content(@wrong_user.email) 
    end 
  end

  private

  def login
    @user = FactoryGirl.create(:user)
    visit '/login'
    fill_in "Email", :with => @user.email
    fill_in "Password", :with => @user.password
    click_button "Sign in"
  end

end