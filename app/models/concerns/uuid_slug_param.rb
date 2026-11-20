# Lets a model whose to_param is "<uuid>-<slug>" be found with that same string.
#
# Integer ids were stripped of their trailing slug by Integer casting. UUIDs are not,
# so the id attribute keeps only the leading UUID. The column stays a uuid, which keeps
# assign_uuid_v7 and every finder (find, association find, CanCanCan) working unchanged.
# Anything that does not start with a UUID casts to nil and raises RecordNotFound.
module UuidSlugParam
  extend ActiveSupport::Concern

  class IdType < ActiveRecord::ConnectionAdapters::PostgreSQL::OID::Uuid
    LEADING_UUID = /\A\h{8}-\h{4}-\h{4}-\h{4}-\h{12}(?=-|\z)/

    private

    def cast_value(value)
      string = value.to_s
      super(string[LEADING_UUID] || string)
    end
  end

  included do
    attribute :id, IdType.new
  end
end
