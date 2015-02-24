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
      can :render_new, Entry
      can :render_new, Theme
      can :search_entry, Theme
      can :check_new, Theme
      can :point_graph, Theme
      can :user_point_ranking, Theme
      can :json_user_point, Theme
      can :create_entry, Theme
      can :check_new_message_2015_1, Theme
    when 'normal'
      can :read, Theme
      can :create, Entry
      can :like, Entry
      can :np, Entry
      can :render_new, Entry
      can :render_new, Theme
      can :search_entry, Theme
      can :check_new, Theme
      can :point_graph, Theme
      can :user_point_ranking, Theme
      can :json_user_point, Theme
      can :create_entry, Theme
      can :check_new_message_2015_1, Theme
    else                        # guest
      can :read, Theme
      can :check_new, Theme
      can :render_new, Theme
      can :search_entry, Theme
      can :check_new_message_2015_1, Theme
      can :load_test_api, Entry
    end
  end
end
