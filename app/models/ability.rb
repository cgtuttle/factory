class Ability
  include CanCan::Ability

  def initialize(user, tenant)    
    role = Membership.where("user_id = ? AND tenant_id = ?", user, tenant).first.role

    case role
    when "root"    
      can :manage, :all
    when "owner"
      can :manage, :all
    when "admin"
      can :manage, :all
    when "manager"
      can :view, :all
      can :manage, [Analysis, Category, Import, Item, ItemSpec, Spec]
    else
      can :display, ItemSpec
    end
  end
end
