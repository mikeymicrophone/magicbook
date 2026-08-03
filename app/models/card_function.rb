class CardFunction < ApplicationRecord
  has_many :parent_relations, class_name: "CardFunctionRelation", foreign_key: :child_function_id,
    dependent: :destroy, inverse_of: :child_function
  has_many :parents, through: :parent_relations, source: :parent_function

  has_many :child_relations, class_name: "CardFunctionRelation", foreign_key: :parent_function_id,
    dependent: :destroy, inverse_of: :parent_function
  has_many :children, through: :child_relations, source: :child_function

  has_many :card_function_assignments, dependent: :destroy
  has_many :card_concepts, through: :card_function_assignments

  validates :name, :slug, presence: true, uniqueness: true

  def to_param
    slug
  end

  def ancestor_ids
    found_ids = []
    frontier = parents.pluck(:id)

    until frontier.empty?
      found_ids.concat(frontier)
      frontier = self.class.joins(:child_relations)
        .where(card_function_relations: { child_function_id: frontier })
        .where.not(id: found_ids)
        .pluck(:id)
    end

    found_ids
  end

  def descendant_ids
    found_ids = []
    frontier = children.pluck(:id)

    until frontier.empty?
      found_ids.concat(frontier)
      frontier = self.class.joins(:parent_relations)
        .where(card_function_relations: { parent_function_id: frontier })
        .where.not(id: found_ids)
        .pluck(:id)
    end

    found_ids
  end

  def card_concepts_including_descendants
    CardConcept.joins(:card_function_assignments)
      .where(card_function_assignments: { card_function_id: [id, *descendant_ids] })
      .distinct
  end
end
