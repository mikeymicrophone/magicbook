class Ability
  include CanCan::Ability

  def initialize user
    if user.is_a? Scribe
      can :manage, :all
    elsif user.is_a? Magician
      can :read, :all
      can :invite, Muggle
      can :submit, Muggle
      can [:free, :next], Chapter
      can :manage, List
      can :manage, ListedItem
      cannot :review, :all
      cannot :approve, :all
      cannot :reject, :all
      cannot :read, Magician
    elsif user.is_a? Muggle
      can :read, :all
      can [:free, :next], Chapter
      cannot :read, Magician
    else
      can :invite, Muggle
      can :read, List
      can [:free, :next], Chapter
      can :index, Book
      can [:new, :suggest_revision], ListedItem
      can :create, ListedItem, :privacy => ListedItem.privacies[:suggested]
      cannot :read, Magician
    end
  end
end
