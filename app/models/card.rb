class Card < ApplicationRecord
  include FlagShihTzu
  
  has_many :card_inclusions
  has_many :listed_items, :through => :card_inclusions
  
  validates :name, :uniqueness => true

  has_flags 1 => :artifact,
            2 => :creature,
            3 => :enchantment,
            4 => :instant,
            5 => :land,
            6 => :planeswalker,
            7 => :sorcery,
            8 => :tribal,
            :column => 'types'
            
  
  has_flags 1 => :white,
            2 => :blue,
            3 => :black,
            4 => :red,
            5 => :green,
            :column => 'colors'
end
