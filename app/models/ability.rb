class Ability
  include CanCan::Ability

  def initialize user
    if user.is_a? Scribe
      can :manage, :all
    elsif user.is_a? Magician
      can :read, :all
    elsif user.is_a? Muggle
      can :read, :all
    end
  end
end