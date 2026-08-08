class Ability
  include CanCan::Ability

  def initialize(user)
    if user.is_a?(Mage) && user.admin?
      can :manage, :all
    elsif user.is_a?(Mage)
      can :read, :all
      can :invite, Invitation
      can :submit, Invitation
      can [:free, :next], Chapter
      can :create, List
      can [:read, :update, :destroy], List, mage_id: user.id
      can :create, ListedItem
      can [:read, :update, :destroy], ListedItem do |listed_item|
        listed_item.list&.mage_id == user.id
      end
      cannot :review, :all
      cannot :approve, :all
      cannot :reject, :all
      cannot :read, Mage
    else
      can :read, List
      can :read, CardSet
      can :read, Card
      can :read, CardFunction
      can [:free, :next], Chapter
      can :index, Book
      can [:new, :suggest_revision], ListedItem
      can :create, ListedItem, :privacy => ListedItem.privacies[:suggested]
      cannot :read, Mage
    end
  end
end
