class CardFunctionRelation < ApplicationRecord
  belongs_to :parent_function, class_name: "CardFunction", inverse_of: :child_relations
  belongs_to :child_function, class_name: "CardFunction", inverse_of: :parent_relations

  validates :child_function_id, uniqueness: { scope: :parent_function_id }
  validate :parent_and_child_must_differ
  validate :must_not_create_cycle

  private

  def parent_and_child_must_differ
    errors.add(:child_function, "cannot be its own parent") if parent_function_id == child_function_id
  end

  def must_not_create_cycle
    return unless parent_function && child_function
    return unless parent_function.ancestor_ids.include?(child_function.id)

    errors.add(:parent_function, "would create a cycle")
  end
end
