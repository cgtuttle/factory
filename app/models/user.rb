class User < ActiveRecord::Base
  validates_uniqueness_of :email

  has_many :memberships, :dependent => :destroy
  has_many :tenants, :through => :memberships
  accepts_nested_attributes_for :memberships
  accepts_nested_attributes_for :tenants

  # Include default devise modules. Others available are:
  # :token_authenticatable, :confirmable,
  # :lockable, :timeoutable and :omniauthable
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :trackable, :validatable

  # Setup accessible (or protected) attributes for your model
  attr_accessible :email, :password, :password_confirmation, :remember_me
  # attr_accessible :title, :body

#  ROLES = %w[root owner admin manager user]

end
