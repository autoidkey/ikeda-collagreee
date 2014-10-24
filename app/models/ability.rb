class Ability
  include CanCan::Ability

  def initialize(user)
    user ||= User.new

    case user.role
    when 'admin'
      can :manage, :all
    when 'facilitator'
      can :read, Theme
      can :manage, Issue
      can :create, Entry
      can :like, Entry
    when 'normal'
      can :read, Theme
      can :create, Entry
      can :like, Entry
    else                        # guest
      can :read, Theme
    end
  end
end
