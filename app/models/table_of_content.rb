class TableOfContent < ActiveRecord::Base
  belongs_to :book, :optional => true
  belongs_to :edition, :optional => true
  belongs_to :chapter, :optional => true
  belongs_to :section, :optional => true
  belongs_to :paragraph, :optional => true
  belongs_to :citation, :optional => true
end
