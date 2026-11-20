class ApplicationRecord < ActiveRecord::Base
  include MarkdownHelper
  self.abstract_class = true

  UUID_FORMAT = /\A[0-9a-f]{8}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{12}\z/i

  before_create :assign_uuid_v7

  private

  def assign_uuid_v7
    return unless self.class.columns_hash["id"]&.type == :uuid

    self.id ||= SecureRandom.uuid_v7(extra_timestamp_bits: 12)
  end
end
