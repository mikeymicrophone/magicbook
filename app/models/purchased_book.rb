class PurchasedBook < ApplicationRecord
  belongs_to :book
  belongs_to :purchase
end
