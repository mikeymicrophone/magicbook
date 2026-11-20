# frozen_string_literal: true

Rails.application.config.to_prepare do
  unless ActiveStorage::Record.method_defined?(:assign_uuid_v7, false)
    ActiveStorage::Record.class_eval do
      before_create :assign_uuid_v7

      private

      def assign_uuid_v7
        return unless self.class.columns_hash["id"]&.type == :uuid

        self.id ||= SecureRandom.uuid_v7(extra_timestamp_bits: 12)
      end
    end
  end
end
