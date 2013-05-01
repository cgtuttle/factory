class Ability
  include CanCan::Ability

  def initialize(user)
    if user.has_role? :root
        can :manage, :all
    elsif user.has_role? :admin
        can :manage, :all
    else
        can :view, :all
    end
  end
end
