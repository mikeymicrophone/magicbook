class Ability
  include CanCan::Ability

  def initialize user
    if user.is_a? Scribe
      can :manage, :all
    elsif user.is_a? Magician
      can :read, :all
      can :invite, Muggle
      can :submit, Muggle
      can :free, Chapter
    elsif user.is_a? Muggle
      can :read, :all
      can :free, Chapter
    else
      can :free, Chapter
    end
  end
end
