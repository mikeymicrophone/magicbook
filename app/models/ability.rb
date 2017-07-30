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
      can :manage, List
      can :manage, ListedItem
      cannot :review, :all
      cannot :approve, :all
      cannot :reject, :all
    elsif user.is_a? Muggle
      can :read, :all
      can :free, Chapter
    else
      can :read, List
      can :free, Chapter
      can :index, Book
      can :new, ListedItem
      can :create, ListedItem, :privacy => 'suggested'
    end
  end
end
