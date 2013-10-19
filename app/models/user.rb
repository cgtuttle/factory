class User < ActiveRecord::Base
  validates_uniqueness_of :email

  has_many :memberships, :dependent => :destroy
  has_many :tenants, :through => :memberships
  accepts_nested_attributes_for :memberships
  accepts_nested_attributes_for :tenants

  # Include default devise modules. Others available are:
  # :token_authenticatable,
  # :lockable, :timeoutable and :omniauthable, :confirmable
  devise :invitable, :database_authenticatable, :registerable,
         :recoverable, :rememberable, :trackable, :validatable

  # Setup accessible (or protected) attributes for your model
  attr_accessible :email, :password, :password_confirmation, :remember_me
  

end
