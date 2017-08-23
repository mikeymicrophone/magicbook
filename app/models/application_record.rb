class ApplicationRecord < ActiveRecord::Base
  include MarkdownHelper
  self.abstract_class = true
end
