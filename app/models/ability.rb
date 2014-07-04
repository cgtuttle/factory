class Ability
  include CanCan::Ability

  def initialize(user, tenant)
    if tenant          
      role = Membership.where("user_id = ? AND tenant_id = ?", user, tenant).first.role.role_name      
    else
      role = "guest"
    end
    
    case role
    when "root"    
      can :manage, :all
    when "owner"
      can :manage, :all 
    when "admin"
      can :manage, :all
      cannot [:update, :create, :destroy], Tenant
    when "manager"
      can :view, :all
      can :manage, [Analysis, Category, Import, Item, Specification, Trait]
    else
      can :display, [Specification]
      can :view, [Tenant]
      can :set, [Tenant]
    end
        
  end
end
