# frozen_string_literal: true

require "active_support/core_ext/module/delegation"

module ActiveStorage
  # Abstract base class for the concrete ActiveStorage::Attached::One and ActiveStorage::Attached::Many
  # classes that both provide proxy access to the blob association for a record.
  class Attached
    attr_reader :name, :record

    def initialize(name, record)
      @name, @record = name, record
    end

    def to_signed_validation_id
      if record.persisted?
        ActiveStorage.verifier.generate("#{record.to_global_id}--#{name}")
      else
        ActiveStorage.verifier.generate("#{record.model_name}--#{name}")
      end
    end

    private
      def change
        record.attachment_changes[name]
      end
  end
end

require "active_storage/attached/model"
require "active_storage/attached/one"
require "active_storage/attached/many"
require "active_storage/attached/changes"
