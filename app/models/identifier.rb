class Identifier < ApplicationRecord
  belongs_to :magician, :optional => true
  belongs_to :muggle, :optional => true
end
