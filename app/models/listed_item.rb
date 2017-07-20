class ListedItem < ApplicationRecord
  belongs_to :list
  belongs_to :content, :polymorphic => true, :optional => true
end
