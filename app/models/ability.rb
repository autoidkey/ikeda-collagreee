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
      can :np, Entry
      can :search_entry, Theme
      can :check_new, Theme
      can :render_new, Entry
    when 'normal'
      can :read, Theme
      can :create, Entry
      can :like, Entry
      can :np, Entry
      can :search_entry, Theme
      can :check_new, Theme
      can :render_new, Entry
    else                        # guest
      can :read, Theme
      can :search_entry, Theme
    end
  end
end
